# Draft: Git Fix Manager Professionalization Plan

## Current State Analysis

### What Works Well
- Core functionality: bug tracking via git notes
- 13/14 detector tests passing (93%)
- Interactive CLI interface (gfm)
- 4 cherry-pick detection heuristics implemented
- Performance < 30s as promised
- Comprehensive test suite (14+ test files)

### Issues Identified

#### Critical (Blocking Professional Release)
1. **Version mismatch across files**
   - README.md: version-1.1.0
   - gfm: VERSION="1.2.0"
   - test-final.sh: expects "2.0.0"
   - Result: test-final.sh fails

2. **File permissions**
   - Scripts not executable by default
   - Users must run `chmod +x` manually

3. **Failing test**
   - detector-negative.sh fails silently
   - 13/14 tests pass (93%)

#### Medium Priority
4. **Inconsistent naming**
   - Some functions use snake_case, others camelCase
   - Mix of French and English in comments

5. **Missing CI/CD integration**
   - No GitHub Actions workflow
   - No automated testing on push

6. **Documentation gaps**
   - No API documentation
   - No contribution guidelines for code style
   - No changelog

#### Nice to Have
7. **Code quality**
   - No linting (shellcheck)
   - No formatting standard
   - Some dead code/comments

8. **Distribution**
   - No Homebrew formula
   - No apt/yum packages
   - Manual installation only

## User Requirements (CONFIRMED)

### Scope
- **Type**: Comprehensive overhaul
- **Audience**: Open source public
- **Timeline**: 1 week sprint
- **Goal**: Tool ready for community adoption

### Non-Negotiables
- All tests must pass (100%)
- Professional CI/CD pipeline
- Clear documentation for contributors
- Easy installation (one-liner)
- No breaking changes to existing functionality

## Proposed Work Areas (To Be Prioritized)

### Wave 1: Critical Fixes (Foundation)
- Fix version synchronization
- Fix file permissions in git
- Fix failing detector-negative test
- Add pre-commit hooks

### Wave 2: Quality & CI (Professional Base)
- Add GitHub Actions workflow
- Add shellcheck linting
- Standardize code style
- Add automated release process

### Wave 3: Documentation & Distribution
- Create proper changelog
- Add man pages
- Create Homebrew formula
- Improve README with badges

### Wave 4: Polish
- Add shell completions (bash/zsh)
- Add integration tests
- Performance benchmarks
- Security audit
