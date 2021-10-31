local ffi = require 'ffi'
local nc = require 'ffi.netcdf'
local ncsafecall = require 'netcdf.safecall'

local function typename(ncid, nctype)
	local typename = ffi.new('char[?]', nc.NC_MAX_NAME+1)
	typename[ffi.sizeof(typename)-1] = 0
	local size = ffi.new('size_t[1]', 0)
	ncsafecall('nc_inq_type', ncid, nctype, typename, size)
	return ffi.string(typename), size
end

return typename
