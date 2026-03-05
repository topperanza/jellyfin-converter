# Security Policy

## Supported Versions

Security fixes are provided for the latest release on the `main` branch.

## Reporting a Vulnerability

Please do not open a public issue for security-sensitive reports.

Send details privately by email to: `security@topperanza.dev`

Include:

- A clear description of the issue and impact.
- Reproduction steps or proof-of-concept.
- Affected version/commit hash.
- Any suggested mitigation.

## Response Targets

- Initial acknowledgement: within 3 business days.
- Triage/update: within 7 business days.
- Fix timeline: depends on severity and complexity.

## Scope

This repository is a local shell-based media conversion tool. Typical security focus areas:

- Command/argument handling and shell injection resistance.
- Unsafe file deletion or path traversal behavior.
- CI/dependency supply-chain integrity.
- Installer/release integrity checks (`checksums.txt`, tamper rejection).

## Supply-chain controls
- GitHub Actions in workflows are pinned to immutable commit SHAs.
- Release artifacts are checksummed (sha256) and validated by installer.
- Installer only supports HTTPS GitHub release download URLs.
- Release pipeline includes action pinning and docs/version synchronization checks.
