# Compile fzy_native:

```
env MACOSX_DEPLOYMENT_TARGET=15.0 gcc -O2 -fPIC -I$HOMEBREW_PREFIX/opt/lua/include/lua5.4 -c src/fzy_native.c -o src/fzy_native.o -DLUA_COMPAT_5_1
env MACOSX_DEPLOYMENT_TARGET=15.0 gcc -O2 -fPIC -I$HOMEBREW_PREFIX/opt/homebrew/opt/lua/include/lua5.4 -c src/match.c -o src/match.o -DLUA_COMPAT_5_1
env MACOSX_DEPLOYMENT_TARGET=15.0 gcc -L$HOMEBREW_PREFIX/opt/curl/lib -bundle -undefined dynamic_lookup -all_load -o fzy_native.so src/fzy_native.o src/match.o
```

## Using german names for system panes

Run `./prefpane_translations.sh` to generate the Lua table and point out missing translations.

`seal_appsfzy.lua` discovers modern System Settings extensions directly from their
`Info.plist` metadata, using the legacy pane name for translations and
`x-apple.systempreferences:` URLs to open the corresponding section. These entries
do not depend on Spotlight indexing the old `.prefPane` paths. Real legacy and
third-party preference pane bundles are also scanned directly; empty stubs are
skipped. Discovery is refreshed when the plugin starts or restarts.
