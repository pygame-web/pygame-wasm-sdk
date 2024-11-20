
CPU=${CPU:-wasm32}
TARGET=${TARGET:-emsdk}

cat > $ROOT/${PYDK_PYTHON_HOST_PLATFORM}-shell.sh <<END
#!/bin/bash
export ROOT=${SDKROOT}
export SDKROOT=${SDKROOT}
. ${SDKROOT}/config

export HOST_PREFIX=$HOST_PREFIX
export PYDK_PYTHON_HOST_PLATFORM=${PYDK_PYTHON_HOST_PLATFORM}
export PLATFORM_TRIPLET=${PYDK_PYTHON_HOST_PLATFORM}

export PATH=${HOST_PREFIX}/bin:\$PATH:${SDKROOT}/devices/${TARGET}/usr/bin:$(echo -n ${SDKROOT}/emsdk/node/*/bin)
export LD_LIBRARY_PATH=${HOST_PREFIX}/lib:${HOST_PREFIX}/lib64:${LD_LIBRARY_PATH}

export PREFIX=$PREFIX
export PYTHONPYCACHEPREFIX=${PYTHONPYCACHEPREFIX:-${SDKROOT}/build/pycache}
mkdir -p \$PYTHONPYCACHEPREFIX

# so pip does not think everything in ~/.local is useable
export HOME=${SDKROOT}

export PYTHONDONTWRITEBYTECODE=1

END


