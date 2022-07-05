import setuptools

filename = "fake_sun/__version__.py"
with open(filename, "rb") as fp:
    code = compile(fp.read(), filename, mode="exec")
    exec(code, globals(), locals())

setuptools.setup(
    name="fake-sun",
    version=__version__,  # noqa
    description="My PWM LED driver for the Raspberry Pi Zero",
    author="Louis Opter",
    author_email="louis@opter.org",
    packages=setuptools.find_packages(exclude=['tests', 'tests.*']),
    include_package_data=True,
    entry_points={
        "console_scripts": [
            "fake-sun = fake_sun.__main__:main",
        ],
    },
    install_requires=[
        "click",
    ],
)
