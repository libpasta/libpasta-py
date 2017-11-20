from setuptools import setup, Extension

pasta = Extension(
    '_pasta',
    sources=['libpasta/pasta_wrap.c'],
    libraries=['pasta'],
    )

setup(
    name='libpasta',
    version='0.0.4',
    author='Sam Scott',
    author_email='me@samjs.co.uk',
    packages=['libpasta'],
    url='http://pypi.python.org/pypi/libpasta/',
    license='LICENSE.md',
    description='Password hashing library',
    long_description=open('README').read(),
    ext_modules = [pasta],
    py_modules = ["libpasta"],
)
