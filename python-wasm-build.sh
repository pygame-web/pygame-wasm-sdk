#!/bin/bash
export LC_ALL=C
export PYTHONDONTWRITEBYTECODE=1
export REBUILD=${REBUILD:-false}
export ROOT=/opt/python-wasm-sdk
mkdir -p /opt/python-wasm-sdk/build/pycache
export HOST_PREFIX=${HOST_PREFIX:-$ROOT/devices/$(arch)/usr}
export PREFIX=${PREFIX:-${ROOT}/devices/emsdk/usr}
export PYTHONPYCACHEPREFIX=$(realpath ${ROOT}/build/pycache)

export HPY=$(echo -n ${HOST_PREFIX}/bin/python3.1?)
export PIP=$(echo -n ${HOST_PREFIX}/bin/pip3.$(echo $HPY|cut -d. -f2))

export CI=${CI:-false}

# cpython build opts
export CPOPTS="-Os -g0 -fPIC"
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# module build opts
export CFLDPFX="$CPPFLAGS $LDFLAGS -Wno-unused-command-line-argument"

if [ -f /opt/python-wasm-sdk/dev ]
then
    export COPTS="-O0 -g3 -fPIC"
    export VERBOSE=""
else
    export COPTS="-Os -g0 -fPIC"
    export VERBOSE="2>&1 > $PYTHONPYCACHEPREFIX/.log"
fi

#stable
# EMFLAVOUR=latest
#git
EMFLAVOUR=tot

export PYDK_PYTHON_HOST_PLATFORM=wasm32-$EMFLAVOUR-emscripten

if echo $LD_LIBRARY_PATH |grep -q ${HOST}/lib
then
    # config already set
    echo -n
else
    #export LD_LIBRARY_PATH="${HOST_PREFIX}/lib:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="${HOST_PREFIX}/lib"
fi

if [[ ! -z ${PYDK+z} ]]
then
    # config already set
    echo -n
else
    mkdir -p src
    export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
    export PATH="${HOST_PREFIX}/bin:$PATH"
    export PYDK=minimal
fi

$@