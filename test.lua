#!/usr/bin/env luajit
local NetCDF = require 'netcdf'
local range = require 'ext.range'
local table = require 'ext.table'

local fn = assert(..., "expected filename")
local netcdf = NetCDF{filename=fn}

-- [[
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
--]]

-- gather cols beforehand, find the max, format accordingly.  extra +1 for indexes
local cols = range(#netcdf.vars+1):mapi(function() return table() end)
for i in netcdf:indexes() do
	cols[1]:insert(table.concat(i, ','))
	for j,var in ipairs(netcdf.vars) do
		cols[j+1]:insert(tostring(var:get(table.unpack(i))))
	end
end


print'values:'
local maxs = cols:mapi(function(col) return (col:mapi(function(s) return #s end):sup()) end)
for i=1,#cols[1] do
	for j,col in ipairs(cols) do
		if j > 1 then
			io.write'   '
		end
		local s = col[i]
		io.write(s..(' '):rep(maxs[j]-#s))
	end
	print()
end
