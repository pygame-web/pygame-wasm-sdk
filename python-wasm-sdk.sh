#!/bin/bash
reset

mkdir -p build/pycache
export PYTHONDONTWRITEBYTECODE=1

# make install cpython will force bytecode generation
export PYTHONPYCACHEPREFIX="$(realpath build/pycache)"

. ${CONFIG:-config}

. scripts/cpython-fetch.sh
. support/__EMSCRIPTEN__.sh
. scripts/cpython-build-host.sh >/dev/null
. scripts/cpython-build-host-deps.sh >/dev/null

# use ./ or emsdk will pollute env
./scripts/emsdk-fetch.sh

echo " ------------------- building cpython wasm -----------------------"
if ./scripts/cpython-build-emsdk.sh > /dev/null
then
    echo " ------------------- building cpython wasm plus -------------------"
    if ./scripts/cpython-build-emsdk-deps.sh > /dev/null
    then
        cd $GITHUB_WORKSPACE
        echo "making tarball"

        mkdir -p sdk
        tar -cpRj config emsdk devices/* prebuilt/* > sdk/python-wasm-sdk-stable.tar.bz2
    else
        echo " cpython-build-emsdk-deps failed"
        exit 2
    fi

else
    echo " cpython-build-emsdk failed"
    exit 1
fi

echo done

