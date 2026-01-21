local ffi = require 'ffi'
local nc = require 'ffi.req' 'netcdf'
local class = require 'ext.class'
local table = require 'ext.table'
local ncsafecall = require 'netcdf.safecall'
local nctypename = require 'netcdf.typename'
local ctypeForNCType = require 'netcdf.ctypefornctype'
local assert = require 'ext.assert'
local Attr = require 'netcdf.attr'


local char_p_1 = ffi.typeof'char*[1]'
local char_arr = ffi.typeof'char[?]'
local int_1 = ffi.typeof'int[1]'
local size_t_arr = ffi.typeof'size_t[?]'
local nc_type_1 = ffi.typeof'nc_type[1]'


local Var = class()

function Var:init(args)
	assert(args)
	self.id = assert.type(args.id, 'number')
	self.nc = assert.type(args.nc, 'table')	-- parent


	local name = char_arr(nc.NC_MAX_NAME+1)
	name[ffi.sizeof(name)-1] = 0
	ncsafecall('nc_inq_varname', self.nc.id, self.id, name)
	self.name = ffi.string(name)
	
	-- conversely, nc_inq_varid gets the id for the name
	local xtype = nc_type_1(0)
	ncsafecall('nc_inq_vartype', self.nc.id, self.id, xtype)
	self.type = xtype[0]

	-- if nc_get_vara has array bounds equal to the main file dims
	-- then what are the var dims for?
	-- and if the var dims are for the var's specific array bounds
	-- then how does the files' dims influence?
	-- does one override the other?
	-- do they cartesian product together?
	local varndims = int_1(0)
	ncsafecall('nc_inq_varndims', self.nc.id, self.id, varndims)
	self.ndims = varndims[0]

	local vardimids = int_1(0)
	ncsafecall('nc_inq_vardimid', self.nc.id, self.id, vardimids)
	self.dimids = vardimids[0]	
		
	--[[ documentation would be nice.  this looks more concise ... but ... causes errors when getting "status" var: "Operation not permitted", because it's a string I guess, ... so ...
	ncsafecall('ncvarinq', self.id, varid, name, xtype, varndims, vardimids, varnatts)
	print('var id', varid, 'type', xtype[0], 'ndims', varndims[0], 'dimids', vardimids[0], 'natts', varnatts[0], 'name', ffi.string(name))
	--]]


	self.attrs = table()
	
	local varnatts = int_1(0)
	ncsafecall('nc_inq_varnatts', self.nc.id, self.id, varnatts)

	for attnum=0,varnatts[0]-1 do
		self.attrs:insert(Attr{
			var = self,
			num = attnum,
		})
	end

	local start = size_t_arr(#self.nc.dims)	-- how big is this? self.ndims it looks like. 
	for i=0,#self.nc.dims-1 do
		start[i] = 0
	end
		
	local count = size_t_arr(#self.nc.dims)	-- what's its extents?  nc.dims[i].value it looks like.
	for i=0,#self.nc.dims-1 do
		count[i] = self.nc.dims[i+1].value
	end
end

function Var:__tostring()
	return 'Var{'
		..'id='..self.id
		..' type="'..nctypename(self.nc.id, self.type)..'"'
		..' ndims='..self.ndims
		..' dimids='..self.dimids
		..' natts='..#self.attrs
		..' name="'..self.name..'"'
	..'}'
end

-- get a single element in the array
function Var:get(...)
	assert.eq(select('#', ...), #self.nc.dims)
	local start = size_t_arr(#self.nc.dims)
	local count = size_t-arr(#self.nc.dims)
	for i=0,#self.nc.dims-1 do
		start[i] = assert.type(select(i+1, ...), 'number')
		count[i] = 1
	end
	
	if self.type == nc.NC_STRING then
		local values = char_p_1()
		ncsafecall('nc_get_vara_string', self.nc.id, self.id, start, count, values)
		local result = ffi.string(values[0])
		ncsafecall('nc_free_string', 1, values)
		return result
	else
		local ctype = ctypeForNCType[self.type]
		local ctypeArr = ffi.typeof('$[?]', ctype)
		local values = ctypeArr(1)	-- I guess this array is the product of count[0]...count[q-1] ?
		ncsafecall('nc_get_vara', self.nc.id, self.id, start, count, values)
		return values[0]
	end
end

return Var 
