# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.0.x   | :white_check_mark: |
| 1.x.x   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in Git Fix Manager, please report it by creating a private security advisory on GitHub.

1. Go to the Security tab of the repository
2. Click "Advisories"
3. Click "New draft security advisory"
4. Fill in the details

We will respond to security reports within 48 hours and aim to release a fix within 7 days.

## Security Measures

This project implements the following security measures:

- All shell scripts use `set -euo pipefail` for strict error handling
- Temporary files are created using `mktemp` with proper cleanup
- User input is validated before processing
- No execution of user-provided strings
- All releases are signed with SHA256 checksums
