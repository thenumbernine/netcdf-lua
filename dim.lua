local ffi = require 'ffi'
local nc = require 'ffi.req' 'netcdf'
local class = require 'ext.class'
local ncsafecall = require 'netcdf.safecall'
local asserttype = require 'ext.assert'.type

local Dim = class()

function Dim:init(args)
	args = args or {}
	self.nc = asserttype(args.nc, 'table')
	self.id = asserttype(args.id, 'number')

	local name = ffi.new('char[?]', nc.NC_MAX_NAME+1)
	local dimptr = ffi.new('size_t[1]', 0)
	name[ffi.sizeof(name)-1] = 0
	ncsafecall('ncdiminq', self.nc.id, self.id, name, dimptr)
	self.name = ffi.string(name)
	self.value = dimptr[0]	-- size or value? value fits with vars and attrs
end

function Dim:__tostring()
	return 'Dim{'
		..'id='..self.id
		..', value='..tostring(self.value)
		..', name="'..self.name
	..'"}'
end

return Dim
