# Makefile for Sphinx documentation
#

# SPDX-FileCopyrightText: © 2020 Open Networking Foundation <support@opennetworking.org>
# SPDX-License-Identifier: Apache-2.0

# use bash for pushd/popd, and to fail quickly
SHELL = bash -e -o pipefail

# You can set these variables from the command line.
SPHINXOPTS   ?= -W
SPHINXBUILD  ?= sphinx-build
SOURCEDIR    ?= .
BUILDDIR     ?= _build

# Create the virtualenv with all the tools installed
VENV_NAME     := venv-docs

# Put it first so that "make" without argument runs "make help".
help: $(VENV_NAME)
	source ./$(VENV_NAME)/bin/activate ; set -u ;\
	$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile test doc8 dict-check sort-dict license clean clean-all

$(VENV_NAME):
	python3 -m venv $@ ;\
	source ./$@/bin/activate ;\
	pip install -r requirements.txt

# test - check that local build will lint, spelling is correct, then
# build the html site.
test: doc8 dict-check spelling linkcheck

# lint all .rst files
doc8: $(VENV_NAME)
	source ./$</bin/activate ; set -u;\
	doc8 --ignore-path $< --ignore-path _build --ignore-path LICENSES --max-line-length 119

# Words in dict.txt must be in the correct alphabetical order and must not duplicated.
dict-check: sort-dict
	@set -u ;\
	git diff --exit-code dict.txt && echo "dict.txt is sorted" && exit 0 || \
	echo "dict.txt is unsorted or needs to be added to git index" ; exit 1

sort-dict:
	@sort -u < dict.txt > dict_sorted.txt
	@mv dict_sorted.txt dict.txt

license: $(VENV_NAME) ## Check license with the reuse tool
	source ./$</bin/activate ; set -u ;\
  reuse --version ;\
  reuse --root . lint

# clean up
clean:
	rm -rf "$(BUILDDIR)"

# clean-all - delete the virtualenv too
clean-all: clean
	rm -rf "$(VENV_NAME)"

# build multiple versions
multiversion: $(VENV_NAME) Makefile
	source $</bin/activate ; set -u ;\
  sphinx-multiversion "$(SOURCEDIR)" "$(BUILDDIR)/multiversion" $(SPHINXOPTS)
	cp "$(SOURCEDIR)/_templates/meta_refresh.html" "$(BUILDDIR)/multiversion/index.html"

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: $(VENV_NAME) Makefile
	source ./$</bin/activate ; set -u;\
	$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
