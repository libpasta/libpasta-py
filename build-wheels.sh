#!/bin/bash
set -e -x

export LIBPASTA_MANYLINUX=1
export DISTUTILS_DEBUG=1
export BUILD_STATIC=1

# Download and install Rust
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
source ~/.cargo/env

# Currently required openssl headers for fastpkdf2. Will probably drop this soon.
yum install -y openssl-devel

rm -rf /opt/python/cp26-*
rm -rf /opt/python/cpython-2.6*

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    "${PYBIN}/pip" install -r /io/dev-requirements.txt
    "${PYBIN}/pip" wheel /io/ -vv -w wheelhouse/
done

# # Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" -w /io/wheelhouse/
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    "${PYBIN}/pip" install libpasta --no-index -f /io/wheelhouse
    (cd "$HOME"; "${PYBIN}/nosetests" libpasta)
done
