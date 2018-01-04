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

# Patch auditwheel to avoid including libresolv
(cd /opt/_internal/cpython-3.6.0/lib/python3.6/site-packages/ && patch -p1) << 'EOF'
diff --git a/auditwheel/policy/policy.json b/auditwheel/policy/policy.json
index ed37aaf..fe13834 100644
--- a/auditwheel/policy/policy.json
+++ b/auditwheel/policy/policy.json
@@ -24,6 +24,6 @@
          "libc.so.6", "libnsl.so.1", "libutil.so.1", "libpthread.so.0",
          "libX11.so.6", "libXext.so.6", "libXrender.so.1", "libICE.so.6",
          "libSM.so.6", "libGL.so.1", "libgobject-2.0.so.0",
-         "libgthread-2.0.so.0", "libglib-2.0.so.0"
+         "libgthread-2.0.so.0", "libglib-2.0.so.0", "libresolv.so.2"
      ]}
 ]
EOF


# Uncomment this to just build one version, useful for debugging.
# export PYVERSIONS=/opt/python/cp27-cp27m/bin
export PYVERSIONS=/opt/python/*/bin


# Compile wheels
for PYBIN in ${PYVERSIONS}; do
    "${PYBIN}/pip" install -r /io/dev-requirements.txt
    "${PYBIN}/pip" wheel /io/ -vv --no-clean -w wheelhouse/
done

# # Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" -w /io/wheelhouse/
done

# Install packages and test
for PYBIN in ${PYVERSIONS}; do
    "${PYBIN}/pip" install libpasta --no-index -f /io/wheelhouse
    (cd "$HOME"; "${PYBIN}/nosetests" libpasta)
done
