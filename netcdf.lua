local ffi = require 'ffi'
local nc = require 'netcdf.lib'
local class = require 'ext.class'
local table = require 'ext.table'
local ncsafecall = require 'netcdf.safecall'
local Var = require 'netcdf.var'
local Dim = require 'netcdf.dim'

local int_1 = ffi.typeof'int[1]'
local int_arr = ffi.typeof'int[?]'

ffi.cdef[[
typedef struct netcdf_file_ncid_t {
	int id[1];
} netcdf_file_ncid_t;
]]
local netcdf_file_ncid_t = ffi.metatype('netcdf_file_ncid_t', {
	__gc = function(self)
		if self.id[0] ~= 0 then
			ncsafecall('nc_close', self.id[0])
			self.id[0] = 0
		end
	end,
})


-- 'File' or 'Database' or ... what?
-- 'CDF' stands for 'common data form' ... so ... 'Data' ?
local NetCDF = class()

function NetCDF:init(args)
	args = args or {}
	if args.filename then

		self.idptr = netcdf_file_ncid_t()
		ncsafecall('nc_open', args.filename, nc.NC_NOWRITE, self.idptr.id)
		self.id = self.idptr.id[0]
--print('ncid', self.id)

		local ndims = int_1(0)
		local nvars = int_1(0)
		local unlimdimid = int_1(0)
		ncsafecall('nc_inq', self.id, ndims, nvars, ngatts, unlimdimid)
		
		local ndims = ndims[0]
		local nvars = nvars[0]
		self.unlimdimid = unlimdimid[0]
--print('ndims', ndims)
--print('nvars', nvars)
--print('unlimdimid', self.unlimdimid)
-- so in this file, unlimdimid == 0 , which should mean the dim with index 0 is unlimited, but it has a size as well ... so ... ?

		-- so I guess 'ndims' is some global thing .... bleh ... why not just .... smh ....
		self.dims = table()	-- 1..ndims, holds .name and .size
		for dimid=0,ndims-1 do
			self.dims:insert(Dim{nc=self, id=dimid})
		end
		assert(#self.dims == ndims)
		-- now our indexs into vara are going to have 'ndims' elements, and dimptr[i] max length, for 0-based i

		self.totalcount = 1
		for i=0,ndims-1 do
			if self.dims[i+1].value ~= 0 then
				self.totalcount = self.totalcount * self.dims[i+1].value
			else
				-- but what happens if it has a size and is unlimited?
				assert(i == self.unlimdimid)
			end
		end

--print('vars:')
		self.vars = table()	-- 1-based ...
		local nvars2 = int_1(0)
		local varids = int_arr(nvars)
		ncsafecall('nc_inq_varids', self.id, nvars2, varids)
		assert(nvars2[0] == nvars)	-- right?
		for i=0,nvars-1 do
			self.vars:insert(Var{
				nc = self,
				id = varids[i],	-- 0-based ...
			})
--print('var id='..varid..' type='..nctypename(self.id, var.type)..' ndims='..var.ndims..' dimids='..var.dimids..' natts='..#var.attrs..' name='..var.name)
		end
	end
end

function NetCDF:indexes()
	return coroutine.wrap(function()
		local i = {}
	
		-- check for empty data, otherwise our iterator will return invalid indexes
		local empty
		for j=1,#self.dims do 
			i[j] = 0 
			-- one of the non-unlimited dimensions has zero size ...
			if self.dims[j].value == 0 and not j-1 == self.unlimdimid then
				empty = true
			end
		end
		if empty then return end

		local done
		repeat
			coroutine.yield(i)
			for j=1,#self.dims do
				i[j] = i[j] + 1
				if i[j] < self.dims[j].value then break end
				i[j] = 0
				if j == #self.dims then done = true end
			end
		until done
	end)
end

return NetCDF 
