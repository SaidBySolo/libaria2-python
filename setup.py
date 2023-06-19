from setuptools import setup

from Cython.Build import cythonize
from Cython.Distutils import Extension

setup(
    ext_modules=cythonize(
        Extension(
            "aria2",
            ["libaria2/aria2.pyx"],
            libraries=["aria2"],
        )
    )
)
