local nc = require 'ffi.req' 'netcdf'

local ctypeForNCType = {
	[nc.NC_BYTE] = 'int8_t',
	[nc.NC_CHAR] = 'char',
	[nc.NC_SHORT] = 'int16_t',
	[nc.NC_INT] = 'int32_t',
	[nc.NC_LONG] = 'int32_t', -- same as NC_INT
	[nc.NC_FLOAT] = 'float',
	[nc.NC_DOUBLE] = 'double',
	[nc.NC_UBYTE] = 'uint8_t',
	[nc.NC_USHORT] = 'uint16_t',
	[nc.NC_UINT] = 'uint32_t',
	[nc.NC_INT64] = 'int64_t',
	[nc.NC_UINT64] = 'uint64_t',
	--[nc.NC_NAT] = not-a-type,
	--[nc.NC_STRING] = string,
}

return ctypeForNCType
