# Developer Notes

## Versioning

During initial development there will be frequent breaking changes to the
software, and the major release number will be incremented frequently.
Follow semantic versioning with a `MAJOR.MINOR` numbering scheme, and not
follow `PATCH` versions during the initial disruptive development.

* `2.0` - a new version with breaking changes from `1.x` series`.
* `2.1` - an update with bug fixes and non-breaking extensions and improvements to `2.0`.
* `2.2-dev` - the version after `2.1` has been released. The next released version
   will be either `2.3` or `3.0`.

The version is defined in the `VERSION` file in the root of the project,
and this file should be used as the input for any process that needs
version information.

## Pull Requests

The PR description should describe the changes being made in the PR, and
be updated to reflect changes made during the review process.

Use "squash and merge" when merging PRs so that each commit to the `master`
branch is a tested and approved version of the tool.
For the commit message, use the text of the PR description.
