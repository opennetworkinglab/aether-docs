Release Process
===============

Prerequisites
-------------

Aether makes the following assumptions about the components are included in a
release:

Git Tags
""""""""

Code receives Git tags as a part of the CI process

* Tag content comes from a **VERSION** file within the repo, and tags are
  created only the version is a SemVer released version (example: ``1.2.3``, no
  ``-dev`` or ``-rc`` extensions)

* Tagging is *only done by the CI system* (Jenkins), which pushes tags to git
  repos after a submit/merge of code which changes the **VERSION** file.

* CI system enforces tag uniqueness - no two commits have the same released
  version tags.

  * You can't re-release or "fix" a version that has problem - make a new
    version with fixes in it.

Docker Container Images
"""""""""""""""""""""""

All docker images are tagged based on their git tags.

* For released versions, the CI system should prevent a Dockerfile from
  referencing a parent containers that are a moving target, such as ``latest``
  or ``master``.

  * This allows a container to be rebuilt given an arbitrary git commit with
    fair confidence that it will result in the same code in the container.

* Official images are only pushed to registries by the CI system

    * Increases repeatability of the process, and prevents human accidents.

Helm Charts
"""""""""""

* Each chart may only contain references to released, SemVer tagged container images

  * Chart CI process must check that a chart version is unique - a chart can't
    be created with the same version twice.  This should be done against the
    chart repo.

Release Steps
-------------

All Helm charts are checked that the containers they use have a SemVer version
tag

A branch is created on the Helm charts repo, with the abbreviated name of the
release - for example **aether-2.1**.

To allow for future patches to go into the repo in a way that does not conflict
with the version branch, each component repo's **VERSION** file should have it's
minor version increased. (ex: 1.2.n to 1.3.0-dev, so future 1.3.n+1 component
release can easily be created).

The same should be done on Helm charts in the chart repos post release, but the
versions there shouldn't include a ``-dev`` suffix because chart publishing
requires that every new chart version be unique and unsuffixed SemVer is a
more consistent release numbering pattern.

Finally, the ``aether-helm-charts`` repo overall **VERSION** should also be incremented
to the next minor version (2.2.0-dev) on the **master** branch, so all 2.1.x
releases of the overall charts repo will happen on the **aether-2.1** branch.

Creating Releases on the 2.1.x Branch
"""""""""""""""""""""""""""""""""""""

If a fix is needed only to the helm charts:

1. Make the fix on the master branch of aether-helm-charts (assuming that it is
   required in both places).

2. After the master tests pass, manually cherry-pick the fix to the **aether-2.1**
   branch (the Chart version would be different, requiring the manual step).

3. Cherry-picked patchsets on that branch will be checked by the **aether-2.1**
   branch of tests.

4. When it passes, submitting the change will make a new 2.1.x release

5. Update the documentation to reflect the chart changes, a description of the
   changes m, and increment the tag on the docs from 2.1.n to 2.1.n+1, to
   reflect the patch change.

6. If all the charts are updated and working correctly, create a new charts
   point release by increasing the 2.1.n **VERSION** file in the
   aether-helm-charts repo.  This should be the same as the version in the
   documentation.  Immediately make another patch that returns the
   ``aether-helm-charts`` **VERSION** to 2.1.n+1-dev, so that development
   patches can continue on that branch.

If a fix is needed to the components/containers that are included by the helm charts:

1. Develop a fix to the issue on the master branch, get it approved after
   passing master tests.

2. If it doesn't exist, create an **aether-2.1** branch on the component repo,
   starting at the commit where the **VERSION** of the component used in 2.1 was
   created - this is known as "lazy branching".


3. Manually cherry-pick to the **aether-2.1** branch of the component, incrementing
   the patch version, and test with the **aether-2.1** version of
   aether-system-tests and helm charts.

4. Update helm charts and go through the helm chart update process above

