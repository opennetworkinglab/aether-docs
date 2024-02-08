.. SPDX-FileCopyrightText: 2021 Open Networking Foundation <info@opennetworking.org>
   SPDX-License-Identifier: Apache-2.0

.. |pub-badge| image:: https://github.com/opennetworkinglab/aether-docs/actions/workflows/publish-docs.yml/badge.svg

|pub-badge|

Aether Docs
===========

This repo contains Sphinx-formated documentation for the Aether project.

Writing Documentation
---------------------

Docs are generated using `Sphinx <https://www.sphinx-doc.org/en/master/usage/>`_ with
`reStructuredText <https://www.sphinx-doc.org/en/master/usage/restructuredtext/>`_ syntax.
A cheat sheet for reStructuredText can be found `here <https://github.com/ralsina/rst-cheatsheet/blob/master/rst-cheatsheet.rst>`_.

Building Documentation
--------------------------

The documentation build process is stored in a ``Makefile``. Building
docs requires Python to be installed, and most steps create a
virtualenv (usually ``venv-docs``) which contains the required tools.
You may also need to install the ``enchant`` C library using your
system's package manager for the spelling checker to function
properly.

Run ``make html`` to generate html documentation in ``_build/html``.

There is also a test target, ``make test``, which will run all the following
checks. This is what happens to validate a patchset.

* ``make lint``: Check the formatting of documentation using `doc8
  <https://github.com/PyCQA/doc8>`_.

* ``make spelling``: Checks spelling on all documentation. If there are
  additional words that are correctly spelled but not in the dictionary
  (acronyms, nouns, etc.) please add them to the ``dict.txt`` file, which
  should be alphabetized using ``sort``

* ``make linkcheck``: Verifies that links in the document are working and
  accessible, using Sphinx's built in linkcheck tool. If there are links that
  don't work with this, please see the ``linkcheck_ignore`` section of
  ``conf.py``.

Versioning Documentation
----------------------------------

To change the version shown on the build site, change the contents of the
``VERSION`` file to be released SemVer version. This will create a tag on the
repo.

The ``make multiversion`` target can then be used to build all
versions tagged or branched on the remote to ``_build/multiversion``. This
uses a fork of `sphinx-multiversion
<https://github.com/Holzhaus/sphinx-multiversion>`_ to build multiple versions
and a menu on the site.

There are variables in ``conf.py`` to determine which tags/branches to build.
