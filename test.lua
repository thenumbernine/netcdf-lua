#!/usr/bin/env luajit
local NetCDF = require 'netcdf'

local fn = assert(..., "expected filename")
local netcdf = NetCDF{filename=fn}

print'dims:'
for _,dim in ipairs(netcdf.dims) do
	print('', dim)
end

print'vars:'
for _,var in ipairs(netcdf.vars) do
	print('', var)
	for _,attr in ipairs(var.attrs) do
		print('', '', attr)
	end
end

print'values:'
for i in netcdf:indexes() do
	io.write(table.concat(i, ','))
	for _,var in ipairs(netcdf.vars) do
		io.write('\t', tostring(var:get(table.unpack(i))))
	end
	print()
end

print'done'

