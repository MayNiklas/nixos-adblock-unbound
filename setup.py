from setuptools import setup

setup(
    name='generate_unbound_conf',
    version='1.0.0',
    url='https://github.com/MayNiklas/shadowplay-sort',
    license='',
    author='MayNiklas',
    author_email='info@niklas-steffen.de',
    description='generate unbound conf from adlist',
    packages=['generate_unbound_conf'],
    entry_points={
        'console_scripts': ['generate-unbound-conf=generate_unbound_conf:main']
    },
)
