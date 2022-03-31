Contributing to Aether
======================

We'd love to accept your patches and contributions to the Aether project. There are
just a few small guidelines you need to follow.

Contributor License Agreement
-----------------------------

Contributions to this project must be accompanied by a Contributor License
Agreement. You (or your employer) retain the copyright to your contribution,
this simply gives us permission to use and redistribute your contributions as
part of the project. Head over to the `ONF CLA <https://cla.opennetworking.org/>`_ to see
your current agreements on file or to sign a new one.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

Guides, Rules and Best Practices
--------------------------------

Aether follows `Google's Engineering Practices <https://google.github.io/eng-practices/>`_,
`Golang Formatting Guide <https://go.dev/doc/effective_go#formatting>`_. Use these documents as a guide when
writing, submitting or reviewing code.
Aether uses Github and gerrit to submit, review, tests and finally merge patches.

Submitting Code
"""""""""""""""

Some additional points for developers:

 - Submit your changes early and often. Input and
   corrections early in the process prevent huge changes later.

 - Please open a ticket in the Aether Jira describing the issue/feature. During the patch please
   preface the commit message with `[AETHER-<jira_number]` e.g. `[AETHER-3400]` so it gets
   automatically linked to the Jira ticket. This keeps code review and design discussions clean.

 - Note that Aether makes use of both gerrit based workflows and Github workflows, depending on
   the component that is being worked on. Follow the section below that is appropriate.

Steps to successful PRs (gerrit workflows)
""""""""""""""""""""""""""""""""""""""""""

 1. Checkout the code and prepare your patch. The workflow to make changes to the Aether code through gerrit is identical
    to the one from `onos-classic` and is described in the
    `Sample Gerrit Workflow page <https://wiki.onosproject.org/display/ONOS/Sample+Gerrit+Workflow>`_

 2. Before submitting the patch via `git review` please execute Aether specific tests:
    `make test` and `make linters`. These commands run unit test, linting and other elements
    to assure the quality of your patch.

 3. Wait for Jenkins sanity checks to pass.
    If the tests fail please fix your patch and then repeat 2 and 3, as necessary.
    **Passing CI verification is mandatory.** If the CI check does not start or fails but you think the issue
    is unrelated you can re-trigger by commenting on to the patch with `recheck`.

 4. When comments are made to your patch please make the appropriate fixes and then
    amend your commit with `git commit --amend` and re-upload to gerrit with `git review`.

 5. Await review. Everyone can comment on code changes, but only Collaborators
    and Core contributors can give final review approval. **All changes must get at least one
    approval**.

Steps to successful PRs (Github workflows)
""""""""""""""""""""""""""""""""""""""""""

 1. Fork the repository to your company or personal Github account.

 2. Checkout the code from your fork of the repo and prepare your patch.

 3. Before submitting the patch via pull request, please execute any Aether specific tests:
    `make test` and `make linters`. These commands run unit test, linting and other elements
    to assure the quality of your patch.

 4. Using the Github user interface on your fork, open a pull request. Add a reviewer from
    the core contributor list whom you believe will be qualified to review your patch. Often
    it helps to be involved in informal conversation with a reviewer.

 5. Wait for Jenkins sanity checks to pass.
    If the tests fail please fix your patch and then repeat 3 through 5, as necessary.
    **Passing CI verification is mandatory.** If the CI check does not start or fails but you think the issue
    is unrelated you can re-trigger by commenting on to the patch with `recheck`.

 6. When comments are made to your patch please make the appropriate fixes and then
    amend your commit with `git commit --amend` and re-upload to gerrit with `git push --force`.
    Alternatively, you may commit your changes as an additional separate commit. Git will usually
    merge subsequent commits into your PR.

 7. Await review. Everyone can comment on code changes, but only Collaborators
    and Core contributors can give final review approval. **All changes must get at least one
    approval**.

Core Contributors
-----------------

Anyone with a Gerrit account can open new issues, comment on existing issues, or
contribute code by opening a review.

A **“core contributor”** is someone who can manage, approve and
merge patches, and create new branches in the main repository.

Core contributors are responsible for maintaining the quality of contributions
to the codebase. The goal of this program is to have a diverse group of
individuals whose expertise in aggregate covers the entire project.

The benefits of being a core contributor include:
- Increased influence of the direction of the project,
- The ability to create branches in the main repository and merge your own code,
- Community recognition and visibility for their contributions and expertise.

Becoming a Core Contributor
"""""""""""""""""""""""""""

Core contributor candidates need to have a demonstrated proficiency with the
Aether codebase and a track record of code reviews.  Members of the Technical
Steering Team (TST) and existing core contributors will regularly invite people
to become new core contributors. Nominations can also be made (including
self-nominations) to the Aether TST (`aether-tst@opennetworking.org`) at any time.

A good nomination will include details about who the person is (including their email
and Github and/or Gerrit username) and outline their experience with the Aether codebase
and project at large.
Nominations are intended to start a conversation that results in a decision to
make the person a core contributor – anyone whose nomination is not initially
approved is encouraged to gain more experience with code submission and code
review in order to gain further mastery over the codebase. Partial approval is
also possible (e.g. a person may be granted the ability to handles patches only
on a certain repository), and full approval may be granted after the contributor
has gained more experience.

New core contributors will be assigned a mentor that is either a TST member or
existing core contributor. The mentor will serve as the primary point of contact
to help onboard the new core contributors and answer any questions they have
with their new responsibilities. The mentor is not the only point of contact,
and core contributors should feel free to reach out to others if and when they
have questions or concerns.

Tips for Core Contributors
""""""""""""""""""""""""""

For your own contributions, you now have the ability to approve and merge your
own code. For larger or potentially controversial reviews, please give the
community an opportunity (at least a few business days) to review your
contribution. Please always ask for comments on the #aether-dev Slack channel.
**With great power comes great responsibility; please don't abuse
this privilege.**

Aether follows `Google’s best practices for code review
<https://google.github.io/eng-practices/review/reviewer/>`_.
You should apply these guidelines strictly and with confidence when reviewing
submissions.

If you are unsure about something in an issue or a review, leave a comment
that outlines your concerns. If a resolution is difficult to reach in the
comments section, the TST meetings are a good place to raise your concerns and
have a discussion.

Current Core Contributors
"""""""""""""""""""""""""

Aether-Roc-Api:

* ``Pushp Raj``

Chronos Exporter:

* ``Pushp Raj``

Subscriber Proxy:

* ``Amit Wankhede``
* ``Pushp Raj``

Prom-Label-Proxy:

* ``Amit Wankhede``

All of the codebase:

* ``Shad Ansari``
* ``Scott Baker``
* ``Andy Bavier``
* ``Hung-Wei Chiu``
* ``Sean Condon``
* ``Kevin Marquardsen``
* ``Hyunsun Moon``
* ``Don Newton``
* ``Matteo Scandolo``
* ``Zack Williams``

Community Guidelines
--------------------

This project follows `Google's Open Source Community Guidelines
<https://opensource.google.com/conduct/>`_
and ONF's
`Code of Conduct <https://docs.opennetworking.org/policies/conduct.html>`.
