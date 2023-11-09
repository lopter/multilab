# Copyright (c) 2017, Louis Opter <louis@opter.org>
#
# This file is part of ofxstatement-us-hsbc.
#
# ofxstatement-us-hsbc is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# ofxstatement-us-hsbc is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import setuptools

version = "0.0.1"

with open('README.rst') as f:
    long_description = f.read()

setuptools.setup(
    name='ofxstatement-us-schwab',
    version=version,
    author="Louis Opter",
    author_email="louis@opter.org",
    url="https://github.com/lopter/ofxstatement-us-schwab",
    description=("Schwab (USA) plugin for ofxstatement"),
    long_description=long_description,
    license="GPLv3",
    keywords=["ofx", "banking", "statement", "schwab", "plugin"],
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Programming Language :: Python :: 3.6',
        'Natural Language :: English',
        'Topic :: Office/Business :: Financial :: Accounting',
        'Topic :: Utilities',
        'Environment :: Console',
        'Operating System :: OS Independent',
        'License :: OSI Approved :: GNU General Public License v3'],
    packages=setuptools.find_namespace_packages("src"),
    package_dir={"": "src"},
    entry_points={
        'ofxstatement': [
            "us-schwab = ofxstatement.plugins.us.schwab:Plugin",
        ]
    },
    install_requires=[
        'ofxstatement',
        "ofxstatement-common",
        'python-dateutil',
    ],
    include_package_data=True,
    zip_safe=True
)
