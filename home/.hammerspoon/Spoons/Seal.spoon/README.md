# compile fzy_native:

```
env MACOSX_DEPLOYMENT_TARGET=11.0 gcc -O2 -fPIC -I/opt/homebrew/opt/lua/include/lua5.4 -c src/fzy_native.c -o src/fzy_native.o -DLUA_COMPAT_5_1
env MACOSX_DEPLOYMENT_TARGET=11.0 gcc -O2 -fPIC -I/opt/homebrew/opt/lua/include/lua5.4 -c src/match.c -o src/match.o -DLUA_COMPAT_5_1
env MACOSX_DEPLOYMENT_TARGET=11.0 gcc -L/opt/homebrew/opt/curl/lib -bundle -undefined dynamic_lookup -all_load -o fzy_native.so src/fzy_native.o src/match.o
```
