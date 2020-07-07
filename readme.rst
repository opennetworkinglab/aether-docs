Documentation Guide
===================

Writing Documentation
---------------------

Docs are generated using `Sphinx <https://www.sphinx-doc.org/en/master/>`_.

Documentation is written in `reStructuredText
<https://www.sphinx-doc.org/en/master/usage/restructuredtext/>`_.

In reStructuredText documents, to create the section hierarchy (mapped in HTML
to ``<h1>`` through ``<h5>``) use these characters to underline headings in the
order given: ``=``, ``-`` ``"``, ``'``, ``^``.

Building the Docs
------------------

The documentation build process is stored in the ``Makefile``. Building docs
requires Python to be installed, and most steps will create a virtualenv
(``venv_docs``) which contains the required tools.  You may also need to
install the ``enchant`` C library using your system's package manager for the
spelling checker to function properly.

Run ``make html`` to generate html documentation in ``_build/html``.

To check the formatting of documentation, run ``make lint``. This will be done
in Jenkins to validate the documentation, so please do this before you create a
patchset.

To check spelling, run ``make spelling``. If there are additional words that
are correctly spelled but not in the dictionary (acronyms, trademarks, etc.)
please add them to the ``dict.txt`` file.

Creating new Versions of Docs
-----------------------------

To change the version shown on the built site, change the contents of the
``VERSION`` file.

There is a ``make multiversion`` target which will build all versions published
on the remote to ``_build``. This will use a fork of `sphinx-multiversion
<https://github.com/Holzhaus/sphinx-multiversion>`_ to build multiple versions
for the site.

Creating Graphs and Diagrams
----------------------------

Multiple tools are available to render inline text-based graphs definitions and
diagrams within the documentation. This is preferred over images as it's easier
to change and see changes over time as a diff.

`Graphviz
<https://www.sphinx-doc.org/en/master/usage/extensions/graphviz.html>`_
supports many standard graph types.

The `blockdiag <http://blockdiag.com/en/blockdiag/sphinxcontrib.html>`_,
`nwdiag, and rackdiag <http://blockdiag.com/en/nwdiag/sphinxcontrib.html>`_,
and `seqdiag <http://blockdiag.com/en/seqdiag/sphinxcontrib.html>`_ suites of
tools can be used to create specific types of diagrams:

- `blockdiag examples <http://blockdiag.com/en/blockdiag/examples.html>`_
- `nwdiag examples <http://blockdiag.com/en/nwdiag/nwdiag-examples.html>`_
- `rackdiag examples <http://blockdiag.com/en/nwdiag/rackdiag-examples.html>`_
- `seqdiag examples <http://blockdiag.com/en/seqdiag/examples.html>`_

The styles applied to nodes and connections in these diagrams can be customized
using `attributes
<http://blockdiag.com/en/blockdiag/attributes/node.attributes.html>`_.
