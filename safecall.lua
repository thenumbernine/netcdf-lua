local ffi = require 'ffi'
local nc = require 'ffi.req' 'netcdf'

-- assumes the return value is zero on success, nonzero on error
local function safecall(f, ...)
	local retval = nc[f](...)
	if retval ~= 0 then
		error(ffi.string(nc.nc_strerror(retval)))
	end
end

return safecall
