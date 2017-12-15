Python bindings for libpasta
===========================

This repository contains the libpasta python bindings.

## Requirements

Currently, only 64-bit linux is supported through manylinux, but we are aiming
to support more platforms.

Both of the below approaches require `libcrypto` usually available through
`libssl` or similar package.


For compiling from source, [SWIG](http://www.swig.org/) is required to produce
the library bindings, but these will be added pregenerated when the library has
stabilised.

## Using libpasta-py

### pypi

The python libpasta bindings have been packaged, and can be installed using
`pip install libpasta`. These are precompiled wheels for linux systems, and
currently include static libpasta bindings and other libraries.

When libpasta is more widely available as a shared library, we will distribute
libpasta-py as a simple wrapper.

Unfortunately, on some systems we are encountering this bug:
https://github.com/psycopg/psycopg2-wheels/issues/2

Which we can patch if it continues being a problem. If Arch is the only affected
system, a source build as below can be used.

### From source

The included `setup.py` file in the libpasta-py repository will build the
package either using a static libpasta, or the shared version.

Both of these depend on the `pasta-bindings/` submodule which contain
the swig bindings, which the setup file handles automatically.
If building the static version (with the `BUILD_STATIC=1` env set)
then additionally the `pasta-bindings/libpasta-ffi` submodule is needed to build
the library. 

In the simplest case, building wrappers for the shared library should be as
straightforward as:
```
git submodule update --init --recursive # update the submodules
python setup.py bdist_wheel # build the wheel file for installation
pip install dist/libpasta-{version}-{build}.whl  # install the library
``` 

And for building the static version (requires Rust)
```
git submodule update --init --recursive # update the submodules
BUILD_STATIC=1 python setup.py bdist_wheel # build the wheel file for installation
pip install dist/libpasta-{version}-{build}.whl  # install the library
```

## Developing libpasta

To build all the wheels for distribution:

`docker run --rm -v `pwd`:/io quay.io/pypa/manylinux1_x86_64 /io/build-wheels.sh`

(Recommended: pre-install Rust and others on a docker image, and comment
out the rustup command)
