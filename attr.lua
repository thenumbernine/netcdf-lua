local ffi = require 'ffi'
local class = require 'ext.class'
local nc = require 'ffi.req' 'netcdf'
local range = require 'ext.range'
local table = require 'ext.table'
local tolua = require 'ext.tolua'
local assert = require 'ext.assert'
local ncsafecall = require 'netcdf.safecall'
local nctypename = require 'netcdf.typename'
local ctypeForNCType = require 'netcdf.ctypefornctype'


local char_p_1 = ffi.typeof'char*[1]'
local char_arr = ffi.typeof'char[?]'
local size_t_1 = ffi.typeof'size_t[1]'
local nc_type_1 = ffi.typeof'nc_type[1]'


local Attr = class()

function Attr:init(args)
	args = args or {}
	for k,v in pairs(args) do
		self[k] = v
	end
	self.var = assert.type(args.var, 'table')
	self.num = assert.type(args.num, 'number')


	local name = char_arr(nc.NC_MAX_NAME+1)
	name[ffi.sizeof(name)-1] = 0
	ncsafecall('nc_inq_attname', self.var.nc.id, self.var.id, self.num, name)
	self.name = ffi.string(name)

	local xtype = nc_type_1(0)
	local len = size_t_1(0)
	-- inq_att queries attribute by-name ...
	ncsafecall('nc_inq_att', self.var.nc.id, self.var.id, self.name, xtype, len)
	self.type = xtype[0]
	self.len = len[0]

	if self.type == nc.NC_STRING then
		self.value = "<idk how to read strings>"
		-- TODO is this nc_get_att_string ?
		local values = char_p_1()	-- how many strings?  self.len?  this file doesn't have string attributes (only char[] attributes ...)
		ncsafecall('nc_get_att_string', self.var.nc.id, self.var.id, self.name, values)
		local result = ffi.string(values[0])
		nc.nc_free_string(1, values)
		self.value = result
	else
		local ctype = ctypeForNCType[self.type]
		local ctypeArr = ffi.typeof('$[?]', ctype)
		local value = ctypeArr(self.len)
		ncsafecall('nc_get_att', self.var.nc.id, self.var.id, self.name, value)
		-- len of strings, i.e. char[]'s, is just #value
		-- len otherwise? is the value array length
		-- for some reason, attrs could store their strings as strings, but would rather store them as char[]'s
		if self.type == nc.NC_CHAR then
			--[[ so luajit can't handle passing a cdata through a function, and then using it as a for-loop bounds
			self.value = range(0,self.len-1):mapi(function(i)
				return string.char(value[i])
			end):concat()
			--]]
			--[[ but luajit can handle cdata primitive types as for-loop bounds?
			local values = table()
			for i=0,self.len-1 do
				values:insert(string.char(value[i]))
			end
			self.value = values:concat()
			--]]
			-- [[ nah it's not that, it's the size_t/uint64_t that luajit for loops choke on
			local values = table()
			local i = 0ull
			while i < self.len do
				values:insert(string.char(value[i]))
				i = i + 1
			end
			self.value = values:concat()
			--]]
		else
			if self.len == 1 then
				self.value = value[0]
			else
				-- should I even bother convert it to a lua table? 
				-- why not just keep it in cdata?
				--[[
				self.value = range(0,self.len-1):mapi(function(i)
					return value[i]
				end)
				--]]
				-- [[
				local ltvalues = table()
				local i = 0ull
				while i < self.len do
					ltvalues:insert(value[i])
					i = i + 1
				end
				self.values = ltvalues
				--]]
			end
		end
	end
end

function Attr:__tostring()
	return 'Attr{'
		..'num='..self.num
		..', name='..tolua(self.name)
		..', type='..nctypename(self.var.nc.id, self.type)
		..', len='..tostring(self.len)
		..', value='..tolua(self.value)
	..'}'
end

return Attr 
