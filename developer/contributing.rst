Contribute to Aether
======================

Users are invited to submit patches and other contributions to the
Aether Project. There are just a few guidelines you need to follow.

Contributor License Agreement
-----------------------------

Contributors sign a `Developer Certificate of Origin (DCO)
<https://wiki.linuxfoundation.org/dco>`__ on each commit, stating that
you agree to the terms published at
https://developercertificate.org/. Aether no longer requires a CLA.

Guides, Rules and Best Practices
--------------------------------

Aether follows `Google's Engineering Practices
<https://google.github.io/eng-practices/>`_, `Golang Formatting Guide
<https://go.dev/doc/effective_go#formatting>`__. Use these documents
as a guide when writing, submitting or reviewing code.  Aether uses
GitHub to submit, review, test and merge patches.

Submit Code
"""""""""""""""

Some additional points for developers:

 - Submit your changes early and often. Input and
   corrections early in the process prevent huge changes later.

 - It is good practice to open a ticket in the `Aether Jira
   <https://lf-aether.atlassian.net/jira/your-work>`__ describing the
   issue/feature. Select the ``Aether (AET)`` Project and the
   appropriate component (e.g., ``OnRamp``, ``SD-Core``, ``SD-RAN``).
   During the patch please preface the commit message with
   ``[AET-<jira_number>]`` so it gets automatically linked to the Jira
   ticket. This keeps code review and design discussions clean.

 - Note that Aether now exclusively uses Github workflows; Gerrit is no
   longer used.

Steps to Successful PRs (Github)
""""""""""""""""""""""""""""""""""""""""""

 1. Fork the repository to your company or personal Github account.

 2. Checkout the code from your fork of the repo and prepare your patch.

 3. Before submitting the patch via a Pull Request, please execute any
    Aether specific tests: `make test` and `make linters`. These
    commands run unit test, linting and other elements to assure the
    quality of your patch.

 4. Using the Github user interface on your fork, open a pull request. Add a reviewer from
    the core contributor list whom you believe will be qualified to review your patch. Often
    it helps to be involved in informal conversation with a reviewer.

 5. Wait for the GitHub sanity checks to pass.  If the tests fail
    please fix your patch and then repeat 3 through 5, as necessary.

 6. When comments are made to your patch, please make the appropriate
    fixes and then commit your changes as an additional separate
    commit. Git usually merges subsequent commits into your original
    PR.

 7. Await review. Everyone can comment on code changes, but only
    Collaborators and Core contributors can give final review approval.

Core Contributors
-----------------

Anyone with a GitHub account can open new issues, comment on existing
issues, or contribute code by opening a review. A **core contributor**
is someone who can manage, approve and merge patches, and create new
branches in the main repository.

Core contributors are responsible for maintaining the quality of
contributions to the codebase. The goal of this program is to have a
diverse group of individuals whose expertise in aggregate covers the
entire project. The benefits of being a core contributor include:

- Increased influence of the direction of the project,
- The ability to create branches in the main repository and merge your own code,
- Community recognition and visibility for their contributions and expertise.

Become a Core Contributor
"""""""""""""""""""""""""""

Core contributor candidates need to have a demonstrated proficiency with the
Aether codebase and a track record of code reviews.  Members of the Technical
Steering Team (TST) and existing core contributors will regularly invite people
to become new core contributors. Nominations can also be made (including
self-nominations) to the Aether TST (`tst@lists.aetherproject.org`) at any time.

A good nomination will include details about who the person is
(including their email and Github username) and outline their
experience with the Aether codebase and project at large.  Nominations
are intended to start a conversation that results in a decision to
make the person a core contributor – anyone whose nomination is not
initially approved is encouraged to gain more experience with code
submission and code review in order to gain further mastery over the
codebase. Partial approval is also possible (e.g. a person may be
granted the ability to handles patches only on a certain repository),
and full approval may be granted after the contributor has gained more
experience.

New core contributors will be assigned a mentor that is either a TST
member or existing core contributor. The mentor will serve as the
primary point of contact to help onboard the new core contributors and
answer any questions they have with their new responsibilities. The
mentor is not the only point of contact, and core contributors should
feel free to reach out to others if and when they have questions or
concerns.

Tips for Core Contributors
""""""""""""""""""""""""""

For your own contributions, you now have the ability to approve and
merge your own code. For larger or potentially controversial reviews,
please give the community an opportunity (at least a few business
days) to review your contribution. Please always ask for comments on
the ``#aether-dev`` Slack channel.  **With great power comes great
responsibility; please don't abuse this privilege.**

Aether follows `Google’s best practices for code review
<https://google.github.io/eng-practices/review/reviewer/>`_.
You should apply these guidelines strictly and with confidence when reviewing
submissions.

If you are unsure about something in an issue or a review, leave a comment
that outlines your concerns. If a resolution is difficult to reach in the
comments section, the TST meetings are a good place to raise your concerns and
have a discussion.

Community Guidelines
--------------------

This project follows the Linux Foundation's `Code of Conduct
<https://docs.linuxfoundation.org/lfx/mentorship/mentor-guide/code-of-conduct>`__.
