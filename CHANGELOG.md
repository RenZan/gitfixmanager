# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-03-03

### Added
- Internationalization (i18n) support with English as default language
- `GFM_LANG` environment variable for language selection (en/fr)
- Shellcheck configuration (`.shellcheckrc`)
- GitHub Actions CI/CD workflows
- GitHub issue and PR templates
- Homebrew formula template
- Version file as single source of truth

### Security
- Fixed RCE vulnerabilities in install scripts
- Replaced predictable temp file paths with `mktemp`
- Added trap-based cleanup for temporary files
- Added input validation framework

### Fixed
- Fixed all 14 tests to pass consistently
- Fixed `set -e` compatibility issues
- Fixed `SHORT_HASH_CACHE` unbound variable
- Fixed `propagate_from_original` return code
- Fixed `list-bugs-current` unbound variable

### Changed
- All test scripts now executable
- Improved error handling throughout codebase

## [1.2.0] - Previous version

### Added
- Interactive mode for guided bug/fix management
- Cherry-pick detection with multiple heuristics
- Automatic note inheritance across branches
- Colorized output
- Update mechanism
