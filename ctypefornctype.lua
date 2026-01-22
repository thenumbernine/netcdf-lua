local ffi = require 'ffi'
local nc = require 'netcdf.ffi.netcdf'

local ctypeForNCType = {
	[nc.NC_BYTE] = ffi.typeof'int8_t',
	[nc.NC_CHAR] = ffi.typeof'char',
	[nc.NC_SHORT] = ffi.typeof'int16_t',
	[nc.NC_INT] = ffi.typeof'int32_t',
	[nc.NC_LONG] = ffi.typeof'int32_t', -- same as NC_INT
	[nc.NC_FLOAT] = ffi.typeof'float',
	[nc.NC_DOUBLE] = ffi.typeof'double',
	[nc.NC_UBYTE] = ffi.typeof'uint8_t',
	[nc.NC_USHORT] = ffi.typeof'uint16_t',
	[nc.NC_UINT] = ffi.typeof'uint32_t',
	[nc.NC_INT64] = ffi.typeof'int64_t',
	[nc.NC_UINT64] = ffi.typeof'uint64_t',
	--[nc.NC_NAT] = not-a-type,
	--[nc.NC_STRING] = string,
}

return ctypeForNCType
