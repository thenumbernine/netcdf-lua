NetCDF LuaJIT library
https://www.unidata.ucar.edu/software/netcdf

I have only desigend it around reading some NOAA files,
the functionality is far from full, no write capabilities yet.

the ffi file is in my https://github.com/thenumbernine/lua-ffi-bindings repo.

Right now it converts attr and dim information into Lua data immediately.
It does not do this with variables though, and waits for them to be queried (via 0-based vectors-of-integers)
