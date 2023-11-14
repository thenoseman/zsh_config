# Compile fzy_native:

```
env MACOSX_DEPLOYMENT_TARGET=11.0 gcc -O2 -fPIC -I$HOMEBREW_PREFIX/opt/lua/include/lua5.4 -c src/fzy_native.c -o src/fzy_native.o -DLUA_COMPAT_5_1
env MACOSX_DEPLOYMENT_TARGET=11.0 gcc -O2 -fPIC -I$HOMEBREW_PREFIX/opt/homebrew/opt/lua/include/lua5.4 -c src/match.c -o src/match.o -DLUA_COMPAT_5_1
env MACOSX_DEPLOYMENT_TARGET=11.0 gcc -L$HOMEBREW_PREFIX/opt/curl/lib -bundle -undefined dynamic_lookup -all_load -o fzy_native.so src/fzy_native.o src/match.o
```

# Seal plugins:



## aws javascript sdk:

Triggered by entering `aws` followed by a space followed by a fuzzy search term. 

Press enter to goto the docs.

Run `node ~/.hammerspoon/Spoons/Seal.spoon/aws-js-sdk/generate.mjs` to create/update the necessary index files.



## aws terraform

Trigger by entering `aws_` followed by a resource/data name (fuzzy matching), press enter to open the browser on the docs page.

Run `~/.hammerspoon/Spoons/Seal.spoon/aws-terraform/generate.sh` to generate the index file.



## node-js

Trigger by entering `n ` followed by a space followed by a fuzzy node js search term. Press enter to open docs.

Run `~/.hammerspoon/Spoons/Seal.spoon/node-js/generate.sh` to generate the index file.
