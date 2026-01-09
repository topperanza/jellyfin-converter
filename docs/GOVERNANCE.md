# Governance & Release Policy

## Release Policy

### Versioning
We follow [Semantic Versioning](https://semver.org/).
- **Major (X.y.z)**: Incompatible API changes or breaking behavior updates.
- **Minor (x.Y.z)**: Backwards-compatible functionality additions.
- **Patch (x.y.Z)**: Backwards-compatible bug fixes.

### Tagging
- Tags must be created for every release.
- Tag format: `vX.Y.Z` (e.g., `v1.0.0`).
- Releases should be accompanied by a changelog entry in `CHANGELOG.md`.

## Branch Protection

We recommend the following branch protection rules for the `main` branch:

### Require a pull request before merging
- **Require approvals**: 1 approval.
- **Dismiss stale pull request approvals when new commits are pushed**: Enabled.

### Require status checks to pass before merging
- **Require branches to be up to date before merging**: Enabled.
- **Status checks**:
  - `ci` (GitHub Actions workflow for tests and linting).

### Include administrators
- Enforce all configured restrictions for administrators.

### Allow force pushes
- **Disabled** (Default).

### Allow deletions
- **Disabled** (Default).
