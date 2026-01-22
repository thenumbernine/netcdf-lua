local ffi = require 'ffi'
local nc = require 'netcdf.ffi.netcdf'
local ncsafecall = require 'netcdf.safecall'

local char_arr = ffi.typeof'char[?]'
local size_t_1 = ffi.typeof'size_t[1]'

local function typename(ncid, nctype)
	local typename = char_arr(nc.NC_MAX_NAME+1)
	typename[ffi.sizeof(typename)-1] = 0
	local size = size_t_1(0)
	ncsafecall('nc_inq_type', ncid, nctype, typename, size)
	return ffi.string(typename), size
end

return typename
