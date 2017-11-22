# setup.py adapted from code found at: https://github.com/kushaldas/liblearn
# from the blog post: https://kushaldas.in/posts/writing-python-extensions-in-rust.html


import os
import sys
import shutil
import subprocess

try:
    from wheel.bdist_wheel import bdist_wheel
except ImportError:
    bdist_wheel = None

from setuptools import setup, find_packages
from distutils.command.build_py import build_py
from distutils.command.build_ext import build_ext
from distutils import log
from setuptools.dist import Distribution
from setuptools import Extension


# Build with clang if not otherwise specified.
if os.environ.get('LIBPASTA_MANYLINUX') == '1':
    os.environ.setdefault('CC', 'gcc')
    os.environ.setdefault('CXX', 'g++')
else:
    os.environ.setdefault('CC', 'clang')
    os.environ.setdefault('CXX', 'clang++')


PACKAGE = 'libpasta'
# Used to produce a build with bundled static library.
# Should not be used outside of dev builds.
BUILD_STATIC = os.environ.get('BUILD_STATIC') == '1'
if BUILD_STATIC:
    EXT_EXT = '.a'
else:
    EXT_EXT = sys.platform == 'darwin' and '.dylib' or '.so'

def build_libpasta(base_path):
    lib_path = os.path.join(base_path, 'libpasta' + EXT_EXT)
    here = os.path.join(os.path.abspath(os.path.dirname(__file__)), "pasta-bindings/libpasta-ffi")
    log.info("%s => %s", here, lib_path)
    cmdline = ['cargo', 'build', '--release']
    if not sys.stdout.isatty():
        cmdline.append('--color=always')
    rv = subprocess.Popen(cmdline, cwd=here).wait()
    if rv != 0:
        sys.exit(rv)

class CustomBuildPy(build_py):
    def run(self):
        self.run_command("build_ext")
        return build_py.run(self)


class CustomBuildExt(build_ext):
    def run(self):
        # if self.inplace: (given up on inplace for now)
        build_py = self.get_finalized_command('build_py')
        if BUILD_STATIC:
            log.info("building static libpasta")
            build_libpasta(self.build_temp)
            for ext in self.extensions:
                lib_path = os.path.join(
                    os.path.abspath(os.path.dirname(__file__)),
                    'pasta-bindings', 'libpasta-ffi', 'target', 'release', 'libpasta' + EXT_EXT
                )
                ext.extra_objects.append(lib_path)
        build_ext.run(self)

cmdclass = {
    'build_ext': CustomBuildExt,
    'build_py': CustomBuildPy,
}

package_dir = {'': '.'}
if os.environ.get('LIBPASTA_MANYLINUX') == '1':
    BUILD_STATIC = True
    pasta = Extension(
        '_libpasta',
        # CentOS5 only has swig 1.3, which doesn't really work
        # Need to run `make python` in pasta-bindings before manylinux build
        ['/io/pasta-bindings/python/pasta_wrap.c'],
        # extra_objects=['libpasta.a'], # This is handled by CustomBuildExt
        libraries=['ssl', 'crypto', 'pthread',  'dl', 'm', 'rt'],
        )

    package_dir = {'': '/io/pasta-bindings/python/'}
elif BUILD_STATIC:
    pasta = Extension(
        '_libpasta',
        ['pasta-bindings/pasta.i'],
        swig_opts=[
            "-outdir", os.path.abspath(os.path.dirname(__file__)),
            "-module", "libpasta",
        ],
        # extra_objects=['libpasta.a'], # This is handled by CustomBuildExt
        libraries=['ssl', 'crypto', 'pthread',  'dl', 'm', 'rt'],
        )
else:
    pasta = Extension(
        '_libpasta',
        ['pasta-bindings/pasta.i'],
        swig_opts=[
            "-outdir", os.path.abspath(os.path.dirname(__file__)),
            "-module", "libpasta",
        ],
        libraries=['ssl', 'pasta'],
        )

setup(
    name='libpasta',
    version='0.0.4.dev3',
    url='https://libpasta.github.io/',
    description='Password hashing library',
    long_description=open('DESC.md').read(),
    license='MIT',
    author='Sam Scott',
    author_email='me@samjs.co.uk',
    packages=find_packages(),
    cmdclass=cmdclass,
    include_package_data=True,
    zip_safe=False,
    platforms='any',
    classifiers=[
        'Development Status :: 1 - Planning',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Topic :: Security :: Cryptography',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],
    ext_modules=[pasta],
    py_modules=['libpasta'],
    package_dir = package_dir
)
