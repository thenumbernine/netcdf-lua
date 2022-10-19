## NetCDF LuaJIT library

[![Donate via Stripe](https://img.shields.io/badge/Donate-Stripe-green.svg)](https://buy.stripe.com/00gbJZ0OdcNs9zi288)<br>
[![Donate via Bitcoin](https://img.shields.io/badge/Donate-Bitcoin-green.svg)](bitcoin:37fsp7qQKU8XoHZGRQvVzQVP8FrEJ73cSJ)<br>
[![Donate via Paypal](https://img.shields.io/badge/Donate-Paypal-green.svg)](https://buy.stripe.com/00gbJZ0OdcNs9zi288)

https://www.unidata.ucar.edu/software/netcdf

I have only desigend it around reading some NOAA files,
The functionality is far from full, no write capabilities yet.

The ffi file is in my https://github.com/thenumbernine/lua-ffi-bindings repo.

Right now it converts attr and dim information into Lua data immediately.
It does not do this with variables though, and waits for them to be queried (via 0-based vectors-of-integers).
