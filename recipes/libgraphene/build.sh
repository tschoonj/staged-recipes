#!/bin/bash

set -xeo pipefail

if [[ "$target_platform" = osx-* ]] ; then
    # the -dead_strip_dylibs option breaks g-ir-scanner in this package: the
    # scanner links a test executable to find paths to dylibs, but with this
    # option the linker strips them out. the resulting error message is
    # "error: can't resolve libraries to shared libraries: ...".
    export ldflags="$(echo $ldflags |sed -e "s/-wl,-dead_strip_dylibs//g")"
    export ldflags_ld="$(echo $ldflags_ld |sed -e "s/-dead_strip_dylibs//g")"
fi

meson_options=(
    --buildtype=release
    --backend=ninja
    -Dgtk_doc=false
    -Dgobject_types=true
    -Dinstalled_tests=false
    -Dlibdir=lib
    -Dintrospection=true
    --wrap-mode=nofallback
)
mkdir forgebuild
cd forgebuild

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$BUILD_PREFIX/lib/pkgconfig"

meson "${meson_options[@]}" --prefix=$PREFIX ..
ninja -j$CPU_COUNT -v
ninja install

