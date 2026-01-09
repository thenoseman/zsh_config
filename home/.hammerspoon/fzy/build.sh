#!/bin/bash
#
# Build fzy on intel/arm
#
arch=$(uname -m)
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="fzy_native_${arch}.so"
prefix=$(brew --prefix)
echo "Building for ${arch} as ${target}"
brew install lua
env MACOSX_DEPLOYMENT_TARGET=15.0 gcc -O2 -fPIC -I${prefix}/opt/lua/include/lua5.4 -c "fzy_native_${arch}.c" -o "fzy_native_${arch}.o" -DLUA_COMPAT_5_1
env MACOSX_DEPLOYMENT_TARGET=15.0 gcc -O2 -fPIC -I${prefix}/opt/lua/include/lua5.4 -c match.c -o match.o -DLUA_COMPAT_5_1
env MACOSX_DEPLOYMENT_TARGET=15.0 gcc -L${prefix}/opt/curl/lib -bundle -undefined dynamic_lookup -all_load -o "${target}" "fzy_native_${arch}.o" match.o

echo "Linking ${target}"
rm "${script_dir}/../${target}" || true
ln -s "${script_dir}/${target}" "${script_dir}/../${target}"
