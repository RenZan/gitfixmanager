# Git Fix Manager Professionalization

## TL;DR

> **Transform Git Fix Manager from a working prototype into a professional, open-source-ready CLI tool.**
>
> **Deliverables**: Security-hardened codebase, 100% passing tests, CI/CD pipeline, multi-platform distribution (Homebrew), English-first i18n, shell completions, man pages, and signed releases.
>
> **Estimated Effort**: Large (1 week sprint, ~25-30 hours of execution)
> **Parallel Execution**: YES - 5 waves with parallel tasks
> **Critical Path**: Security fixes → Tests → CI/CD → Documentation → Release

---

## Context

### Original Request
Professionaliser Git Fix Manager pour publication open source en 1 semaine.

### Current State Analysis
- **Core functionality**: ✅ Working (git notes for bug tracking, cherry-pick detection)
- **Test coverage**: ⚠️ 13/14 tests passing (93%)
- **Code quality**: ⚠️ Functional but inconsistent (mixed naming, French-only, no linting)
- **Distribution**: ❌ Manual installation only (`curl | bash`)
- **CI/CD**: ❌ None
- **Security**: ⚠️ RCE risks in install scripts, temp file handling issues
- **i18n**: ❌ French-only (blocks global adoption)

### Metis Review - Critical Findings
**Security gaps identified:**
- RCE vulnerability in install.sh sed injection
- Command injection risks in user input handling
- No checksum/integrity verification
- Temp files not using mktemp consistently

**Adoption blockers:**
- French-only interface (3% of dev population vs English 100%)
- No shell completions (bash/zsh)
- No man page
- No GitHub Actions / automated testing
- macOS portability issues (GNU vs BSD date)

**Missing infrastructure:**
- Version synchronization chaos (1.1.0 vs 1.2.0 vs 2.0.0)
- No changelog, security policy, issue templates
- No automated release signing
- No Homebrew formula

---

## Work Objectives

### Core Objective
Transform Git Fix Manager into a production-ready CLI tool suitable for open source community adoption, with emphasis on security, internationalization, and professional distribution.

### Concrete Deliverables
- `gfm` - Hardened main script with i18n support
- `scripts/missing-fix-detector.sh` - Security-audited detector
- `.github/workflows/` - CI/CD pipeline (test, lint, security, release)
- `install.sh` - Signed, verified installation script
- `completions/` - Shell completions (bash, zsh, fish)
- `man/gfm.1` - Manual page
- `Formula/gfm.rb` - Homebrew formula
- `CHANGELOG.md` - Version history
- `SECURITY.md` - Vulnerability reporting process
- 100% test pass rate (fix detector-negative.sh)

### Definition of Done
- [ ] All shellcheck warnings resolved (severity: warning+)
- [ ] All tests pass (14/14, 100%)
- [ ] GitHub Actions CI green on Ubuntu + macOS
- [ ] Security scan (CodeQL) passes
- [ ] English interface works (`GFM_LANG=en gfm help`)
- [ ] Version synchronized across all files
- [ ] Homebrew install works (`brew install gfm`)
- [ ] Signed release artifacts available

### Must Have
- Security fixes (RCE, injection, temp files)
- English default with i18n framework
- Version single source of truth
- All tests passing
- GitHub Actions CI/CD
- Shellcheck integration
- Homebrew formula

### Must NOT Have (Guardrails)
- NO new features until foundation is solid
- NO breaking changes to existing command API
- NO French-only releases
- NO unsigned distribution artifacts
- NO curl|bash as primary installation method

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: YES (14 test files in tests/)
- **Automated tests**: TDD approach for fixes, then tests-after for new features
- **Framework**: bash/bats (existing test suite)
- **CI Integration**: GitHub Actions runs all tests on Ubuntu + macOS

### QA Policy
Every task MUST include agent-executed QA scenarios. Evidence saved to `.sisyphus/evidence/`.

- **Security tests**: Run shellcheck, CodeQL scan
- **Functional tests**: Run test suite, verify exit codes
- **i18n tests**: Verify English output
- **Distribution tests**: Install via Homebrew, verify binary works
- **Cross-platform**: Test on both Linux and macOS

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately - Security & Foundation):
├── Task 1: Security hardening - fix RCE and injection vulnerabilities [unspecified-high]
├── Task 2: Fix temp file handling - use mktemp everywhere [quick]
├── Task 3: Create VERSION file - single source of truth [quick]
├── Task 4: Fix failing test detector-negative.sh [deep]
└── Task 5: Add input validation/sanitization [unspecified-high]

Wave 2 (After Wave 1 - i18n & Code Quality):
├── Task 6: Implement i18n framework (English default) [deep]
├── Task 7: Add shellcheck configuration and fix all warnings [unspecified-high]
├── Task 8: Standardize code style (naming, error handling) [quick]
├── Task 9: Fix macOS portability (GNU vs BSD date) [unspecified-high]
└── Task 10: Add pre-commit hooks [quick]

Wave 3 (After Wave 2 - CI/CD):
├── Task 11: Create GitHub Actions CI workflow (test + lint) [unspecified-high]
├── Task 12: Create GitHub Actions release workflow [unspecified-high]
├── Task 13: Create GitHub Actions security scan workflow [unspecified-high]
├── Task 14: Add CodeQL analysis [quick]
└── Task 15: Create issue/PR templates [writing]

Wave 4 (After Wave 3 - Distribution):
├── Task 16: Create shell completions (bash, zsh, fish) [quick]
├── Task 17: Create man page [writing]
├── Task 18: Create Homebrew formula [unspecified-high]
├── Task 19: Update install.sh with signature verification [unspecified-high]
└── Task 20: Create release automation [unspecified-high]

Wave 5 (After Wave 4 - Documentation & Polish):
├── Task 21: Create CHANGELOG.md [writing]
├── Task 22: Create SECURITY.md [writing]
├── Task 23: Update README.md with new install instructions [writing]
├── Task 24: Add badges and shields [quick]
└── Task 25: Final integration test [deep]

Wave FINAL (After ALL tasks - Review):
├── Task F1: Security audit (oracle) - verify all RCE fixed
├── Task F2: Cross-platform QA (unspecified-high) - test on Linux + macOS
├── Task F3: Documentation review (writing) - verify all docs accurate
└── Task F4: Release preparation (deep) - tag v2.0.0, create release

Critical Path: Task 1 → Task 4 → Task 6 → Task 11 → Task 18 → Task 25 → F1-F4
Parallel Speedup: ~60% faster than sequential
Max Concurrent: 5 tasks (Waves 1 & 2)
```

### Dependency Matrix

| Task | Blocked By | Blocks |
|------|-----------|--------|
| 1 (Security) | - | 4, 6, 11, 3 |
| 2 (Temp files) | - | 1 |
| 3 (VERSION) | - | 6, 11, 20 |
| 4 (Fix test) | 1 | 11 |
| 5 (Input validation) | 1 | 11 |
| 6 (i18n) | 1, 3 | 11, 21 |
| 7 (Shellcheck) | 1 | 11 |
| 8 (Code style) | 1 | 11 |
| 9 (Portability) | - | 11 |
| 10 (Pre-commit) | 7 | - |
| 11 (CI workflow) | 4, 6, 7 | 20 |
| 12 (Release workflow) | 11 | 20 |
| 13 (Security workflow) | 1 | - |
| 14 (CodeQL) | 1 | - |
| 15 (Templates) | - | - |
| 16 (Completions) | 6 | 17, 18 |
| 17 (Man page) | 6 | 21 |
| 18 (Homebrew) | 3, 12 | 19 |
| 19 (Install.sh) | 12 | 20 |
| 20 (Release automation) | 12, 18, 19 | F4 |
| 21 (Changelog) | 6, 17 | F4 |
| 22 (Security.md) | 1 | F4 |
| 23 (README) | 6, 18, 19 | F4 |
| 24 (Badges) | 11 | - |
| 25 (Integration) | 11, 16, 17, 18 | F1-F4 |

### Agent Dispatch Summary

- **Wave 1**: **5** → T1: `unspecified-high`, T2: `quick`, T3: `quick`, T4: `deep`, T5: `unspecified-high`
- **Wave 2**: **5** → T6: `deep`, T7: `unspecified-high`, T8: `quick`, T9: `unspecified-high`, T10: `quick`
- **Wave 3**: **5** → T11: `unspecified-high`, T12: `unspecified-high`, T13: `unspecified-high`, T14: `quick`, T15: `writing`
- **Wave 4**: **5** → T16: `quick`, T17: `writing`, T18: `unspecified-high`, T19: `unspecified-high`, T20: `unspecified-high`
- **Wave 5**: **5** → T21: `writing`, T22: `writing`, T23: `writing`, T24: `quick`, T25: `deep`
- **Wave FINAL**: **4** → F1: `oracle`, F2: `unspecified-high`, F3: `writing`, F4: `deep`

---

## TODOs

> Implementation + Test = ONE Task. Never separate.
> EVERY task MUST have: Recommended Agent Profile + Parallelization info + QA Scenarios.
> **A task WITHOUT QA Scenarios is INCOMPLETE. No exceptions.**

### Wave 1: Security & Foundation (Start Immediately)

- [ ] **Task 1: Security Hardening - Fix RCE and Injection Vulnerabilities**

  **What to do**:
  - Fix sed injection in `install.sh:86` (quote INSTALL_DIR properly)
  - Fix command injection in `gfm` where user input flows to git commands
  - Add input validation for bug descriptions (escape special chars)
  - Replace all `eval` patterns with safer alternatives
  - Add sanitization for all user-provided strings before shell execution

  **Must NOT do**:
  - Do NOT change functionality, only harden against injection
  - Do NOT break existing command API

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` (security-critical bash scripting)
  - **Skills**: `git-master` (for understanding git command flow)
  - **Skills Evaluated but Omitted**: `frontend-ui-ux` (not applicable)

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 2, 3, 4, 5)
  - **Blocks**: Tasks 4, 6, 11, 3
  - **Blocked By**: None (can start immediately)

  **References**:
  - `install.sh:86` - Sed injection vulnerability location
  - `gfm:185` - Command injection risk in user input
  - `scripts/missing-fix-detector.sh:328` - Bug description insertion point
  - Shell security best practices: https://sipb.mit.edu/doc/safe-shell/

  **Acceptance Criteria**:
  - [ ] shellcheck reports no SC2026, SC2086, SC2046 warnings for injection risks
  - [ ] Manual test: `gfm bug '"; rm -rf /; "'` doesn't execute malicious code
  - [ ] Manual test: `gfm bug '$(whoami)'` displays literally, doesn't execute

  **QA Scenarios**:

  ```
  Scenario: Command injection protection - happy path
    Tool: Bash
    Preconditions: Clean git repo with gfm installed
    Steps:
      1. Run: gfm bug "Normal bug description"
      2. Verify: Bug is marked without errors
      3. Check: git notes --ref=bugs show HEAD contains "Normal bug description"
    Expected Result: Bug marked successfully, description stored literally
    Evidence: .sisyphus/evidence/task-1-injection-safe.txt

  Scenario: Command injection protection - malicious input
    Tool: Bash
    Preconditions: Clean git repo with gfm installed
    Steps:
      1. Run: gfm bug '"; echo PWNED; "'
      2. Verify: No "PWNED" appears in output
      3. Check: git notes --ref=bugs show HEAD contains literal '"; echo PWNED; "'
    Expected Result: Input treated as literal string, no command execution
    Failure Indicators: "PWNED" appears in output = RCE vulnerability present
    Evidence: .sisyphus/evidence/task-1-injection-blocked.txt
  ```

  **Evidence to Capture**:
  - [ ] shellcheck output saved to task-1-shellcheck.log
  - [ ] Manual injection test results

  **Commit**: YES
  - Message: `security: fix RCE and command injection vulnerabilities`
  - Files: `install.sh`, `gfm`, `scripts/missing-fix-detector.sh`
  - Pre-commit: `shellcheck install.sh gfm scripts/*.sh`

---

- [ ] **Task 2: Fix Temp File Handling - Use mktemp Everywhere**

  **What to do**:
  - Replace `/tmp/missing_fixes_$$` pattern with `mktemp`
  - Audit all temp file usage in scripts
  - Ensure temp files are cleaned up on exit (trap)
  - Add proper error handling for mktemp failures

  **Must NOT do**:
  - Do NOT use predictable temp file names (PID-based)
  - Do NOT leave temp files behind after execution

  **Recommended Agent Profile**:
  - **Category**: `quick` (straightforward refactoring)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 3, 4, 5)
  - **Blocks**: Task 1 (dependency for security audit)
  - **Blocked By**: None

  **References**:
  - `scripts/missing-fix-detector.sh:547` - Temp file usage: `/tmp/missing_fixes_$$`
  - CWE-377: Insecure Temporary File
  - `mktemp` man page for proper usage

  **Acceptance Criteria**:
  - [ ] No hardcoded /tmp/ paths with $$ in codebase
  - [ ] All temp files use `mktemp`
  - [ ] Trap cleanup registered for all temp files

  **QA Scenarios**:

  ```
  Scenario: Temp file security
    Tool: Bash
    Preconditions: Running gfm check command
    Steps:
      1. Run: gfm check main 2>&1
      2. During execution, list /tmp/ for gfm-related temp files
      3. After completion, verify no gfm temp files remain
    Expected Result: Temp files created with random names, cleaned up on exit
    Evidence: .sisyphus/evidence/task-2-temp-files.txt
  ```

  **Commit**: YES
  - Message: `security: use mktemp for all temporary files`
  - Files: `scripts/missing-fix-detector.sh`

---

- [ ] **Task 3: Create VERSION File - Single Source of Truth**

  **What to do**:
  - Create `VERSION` file at repo root with content `2.0.0`
  - Update `gfm` to source VERSION file
  - Update `install.sh` to read VERSION file
  - Update README.md badge to use VERSION file
  - Update test-final.sh to read VERSION file

  **Must NOT do**:
  - Do NOT hardcode version in multiple places
  - Do NOT use different versions in different files

  **Recommended Agent Profile**:
  - **Category**: `quick` (simple file creation and updates)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 2, 4, 5)
  - **Blocks**: Tasks 6, 11, 20 (version-dependent tasks)
  - **Blocked By**: None

  **References**:
  - `gfm:9` - Current hardcoded version
  - `README.md:4` - Badge version
  - `tests/test-final.sh:114` - Version test

  **Acceptance Criteria**:
  - [ ] VERSION file exists with `2.0.0`
  - [ ] grep 'VERSION=' gfm shows source command, not hardcoded value
  - [ ] test-final.sh passes version check

  **QA Scenarios**:

  ```
  Scenario: Version synchronization
    Tool: Bash
    Steps:
      1. cat VERSION → shows 2.0.0
      2. grep VERSION gfm | head -1 → shows source command
      3. ./gfm --version → outputs "Git Fix Manager v2.0.0"
    Expected Result: Single VERSION file drives all version displays
    Evidence: .sisyphus/evidence/task-3-version.txt
  ```

  **Commit**: YES
  - Message: `chore: add VERSION file as single source of truth`
  - Files: `VERSION`, `gfm`, `README.md`, `tests/test-final.sh`

---

- [ ] **Task 4: Fix Failing Test detector-negative.sh**

  **What to do**:
  - Debug why detector-negative.sh fails (silent failure observed)
  - Identify root cause: likely assertion or exit code issue
  - Fix the test or fix the underlying code
  - Ensure test passes consistently

  **Must NOT do**:
  - Do NOT disable the test (must fix root cause)
  - Do NOT change test semantics (still tests negative case)

  **Recommended Agent Profile**:
  - **Category**: `deep` (requires debugging and root cause analysis)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 2, 3, 5)
  - **Blocks**: Task 11 (CI requires all tests passing)
  - **Blocked By**: Task 1 (security fixes may affect behavior)

  **References**:
  - `tests/detector-negative.sh` - Failing test
  - `tests/detector-common.sh` - Test utilities
  - `scripts/missing-fix-detector.sh:670-677` - Exit code handling

  **Acceptance Criteria**:
  - [ ] bash tests/detector-negative.sh exits with code 0
  - [ ] Output shows "NEGATIVE: PASS"
  - [ ] All 14 tests pass when run together

  **QA Scenarios**:

  ```
  Scenario: Negative test passes
    Tool: Bash
    Steps:
      1. Run: bash tests/detector-negative.sh
      2. Check exit code: echo $?
      3. Verify output contains "NEGATIVE: PASS"
    Expected Result: Exit code 0, PASS message present
    Evidence: .sisyphus/evidence/task-4-negative-test.txt
  ```

  **Commit**: YES
  - Message: `test: fix detector-negative.sh failing test`
  - Files: `tests/detector-negative.sh` or `scripts/missing-fix-detector.sh`

---

- [ ] **Task 5: Add Input Validation and Sanitization**

  **What to do**:
  - Add validation functions for bug IDs (format: BUG-YYYYMMDD-XXXX)
  - Add validation for commit hashes (7-40 hex chars)
  - Sanitize bug descriptions (escape shell special chars)
  - Add length limits (prevent DoS via huge inputs)
  - Return helpful error messages for invalid inputs

  **Must NOT do**:
  - Do NOT silently truncate inputs (explicit error instead)
  - Do NOT allow empty bug descriptions

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` (input validation is security-critical)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 2, 3, 4)
  - **Blocks**: Task 11
  - **Blocked By**: Task 1

  **References**:
  - `gfm:165` - BUG-ID regex pattern already exists
  - `scripts/missing-fix-detector.sh:312-314` - mark-bug parameter validation

  **Acceptance Criteria**:
  - [ ] gfm bug "" → error "Description required"
  - [ ] gfm fix INVALID-ID → error "Invalid bug ID format"
  - [ ] gfm bug "$(printf 'A%.0s' {1..10000})" → error "Description too long"

  **QA Scenarios**:

  ```
  Scenario: Input validation - empty description
    Tool: Bash
    Steps:
      1. Run: gfm bug ""
    Expected Result: Error message, exit code 1, no bug marked
    Evidence: .sisyphus/evidence/task-5-empty-input.txt

  Scenario: Input validation - oversized input
    Tool: Bash
    Steps:
      1. Run: gfm bug "$(python3 -c 'print("A"*10000)')"
    Expected Result: Error "Description too long (max 500 chars)", exit code 1
    Evidence: .sisyphus/evidence/task-5-oversized-input.txt
  ```

  **Commit**: YES
  - Message: `feat: add input validation and sanitization`
  - Files: `gfm`, `scripts/missing-fix-detector.sh`

---

### Wave 2: i18n & Code Quality (After Wave 1)

- [ ] **Task 6: Implement i18n Framework (English Default)**

  **What to do**:
  - Create `locales/en.json` and `locales/fr.json` with all UI strings
  - Create i18n loader function in gfm (reads GFM_LANG env var)
  - Extract all French strings from gfm to locale files
  - Replace hardcoded strings with i18n lookups
  - Default to English when GFM_LANG not set
  - Support GFM_LANG=en, GFM_LANG=fr

  **Must NOT do**:
  - Do NOT break existing French functionality
  - Do NOT use external dependencies (pure bash solution)

  **Recommended Agent Profile**:
  - **Category**: `deep` (architectural change)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO (large task, needs focus)
  - **Blocked By**: Tasks 1, 3
  - **Blocks**: Tasks 11, 16, 17, 21

  **References**:
  - `gfm:226` - "Marquer un bug" (example string to extract)
  - `gfm:604-618` - Help text in French
  - GNU gettext as reference (but implement simple bash version)

  **Acceptance Criteria**:
  - [ ] GFM_LANG=en ./gfm help → output in English
  - [ ] GFM_LANG=fr ./gfm help → output in French
  - [ ] ./gfm help (no env) → output in English (default)
  - [ ] All strings externalized to locale files

  **QA Scenarios**:

  ```
  Scenario: English localization
    Tool: Bash
    Steps:
      1. Run: GFM_LANG=en ./gfm help
      2. Check: Output contains "Mark a bug" not "Marquer un bug"
      3. Run: GFM_LANG=en ./gfm bug "Test" 2>&1
      4. Check: Contains "Bug marked" not "Bug marqué"
    Expected Result: All UI in English
    Evidence: .sisyphus/evidence/task-6-english.txt

  Scenario: French localization preserved
    Tool: Bash
    Steps:
      1. Run: GFM_LANG=fr ./gfm help
      2. Check: Output contains "Marquer un bug"
    Expected Result: French still works
    Evidence: .sisyphus/evidence/task-6-french.txt
  ```

  **Commit**: YES
  - Message: `feat: add i18n support with English as default`
  - Files: `locales/en.json`, `locales/fr.json`, `gfm`, `scripts/missing-fix-detector.sh`

---

- [ ] **Task 7: Add Shellcheck Configuration and Fix All Warnings**

  **What to do**:
  - Create `.shellcheckrc` configuration file
  - Fix all shellcheck warnings severity: warning and above
  - Add shellcheck to pre-commit hooks
  - Document shellcheck usage in CONTRIBUTING.md

  **Must NOT do**:
  - Do NOT ignore warnings with shellcheck disable comments (unless documented)
  - Do NOT change functionality while fixing warnings

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` (code quality)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 8, 9)
  - **Blocks**: Task 11
  - **Blocked By**: Task 1

  **References**:
  - Shellcheck documentation: https://github.com/koalaman/shellcheck
  - Current warnings: run `shellcheck gfm scripts/*.sh install*.sh`

  **Acceptance Criteria**:
  - [ ] shellcheck --severity=warning gfm scripts/*.sh returns exit 0
  - [ ] .shellcheckrc exists with project-specific settings
  - [ ] Pre-commit hook runs shellcheck

  **QA Scenarios**:

  ```
  Scenario: Shellcheck passes
    Tool: Bash
    Steps:
      1. Run: shellcheck --severity=warning gfm scripts/*.sh install*.sh
      2. Check exit code: echo $?
    Expected Result: Exit code 0, no warnings
    Evidence: .sisyphus/evidence/task-7-shellcheck.txt
  ```

  **Commit**: YES
  - Message: `style: fix all shellcheck warnings and add config`
  - Files: `.shellcheckrc`, `gfm`, `scripts/*.sh`, `install*.sh`

---

- [ ] **Task 8: Standardize Code Style (Naming, Error Handling)**

  **What to do**:
  - Standardize function naming (choose snake_case or camelCase, apply everywhere)
  - Standardize error handling (all functions return consistent exit codes)
  - Add function documentation headers
  - Group related functions together
  - Remove dead code and unused variables

  **Must NOT do**:
  - Do NOT change function behavior
  - Do NOT break public API (command-line interface)

  **Recommended Agent Profile**:
  - **Category**: `quick` (refactoring)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 7, 9)
  - **Blocks**: Task 11
  - **Blocked By**: Task 1

  **References**:
  - `gfm:54` - get_current_branch_name (snake_case example)
  - `gfm:160` - detectContext (camelCase example - inconsistent!)

  **Acceptance Criteria**:
  - [ ] All functions use consistent naming convention
  - [ ] No mixed snake_case/camelCase in function names
  - [ ] All functions have consistent error return patterns

  **QA Scenarios**:

  ```
  Scenario: Code style consistency
    Tool: Bash
    Steps:
      1. Run: grep -E '^[a-zA-Z_]+\(\)' gfm | head -20
      2. Verify: All function names follow same convention
    Expected Result: Consistent naming (all snake_case or all camelCase)
    Evidence: .sisyphus/evidence/task-8-style.txt
  ```

  **Commit**: YES
  - Message: `refactor: standardize code style and naming`
  - Files: `gfm`, `scripts/missing-fix-detector.sh`

---

- [ ] **Task 9: Fix macOS Portability (GNU vs BSD Date)**

  **What to do**:
  - Fix `gfm:185` GNU date syntax to work on both Linux and macOS
  - Create helper function for cross-platform date operations
  - Test on both GNU and BSD date implementations
  - Handle other GNU-specific utilities if found

  **Must NOT do**:
  - Do NOT assume GNU coreutils on macOS
  - Do NOT break Linux compatibility

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` (cross-platform compatibility)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 7, 8)
  - **Blocks**: Task 11
  - **Blocked By**: None

  **References**:
  - `gfm:185` - GNU-specific date: `date -d "1 year ago"`
  - macOS BSD date uses `date -v-1y` instead

  **Acceptance Criteria**:
  - [ ] gfm works on macOS without GNU coreutils
  - [ ] gfm works on Linux as before
  - [ ] Date calculations produce same results on both platforms

  **QA Scenarios**:

  ```
  Scenario: macOS date compatibility
    Tool: Bash
    Preconditions: Run on macOS (or simulate BSD date)
    Steps:
      1. Run: ./gfm (triggers date calculation in find_bug_commit)
      2. Verify: No "invalid date" errors
    Expected Result: Works on macOS without GNU date
    Evidence: .sisyphus/evidence/task-9-macos.txt
  ```

  **Commit**: YES
  - Message: `fix: make date operations portable (GNU and BSD)`
  - Files: `gfm`

---

- [ ] **Task 10: Add Pre-commit Hooks**

  **What to do**:
  - Create `.pre-commit-config.yaml` for pre-commit framework
  - Add shellcheck hook
  - Add trailing whitespace hook
  - Add end-of-file-fixer hook
  - Document installation in CONTRIBUTING.md

  **Must NOT do**:
  - Do NOT add hooks that require external dependencies not in README

  **Recommended Agent Profile**:
  - **Category**: `quick` (configuration)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Blocked By**: Task 7 (shellcheck config)
  - **Blocks**: None

  **References**:
  - pre-commit framework: https://pre-commit.com/
  - Similar projects' .pre-commit-config.yaml files

  **Acceptance Criteria**:
  - [ ] .pre-commit-config.yaml exists and is valid
  - [ ] pre-commit install works
  - [ ] Shellcheck runs on commit

  **QA Scenarios**:

  ```
  Scenario: Pre-commit hooks
    Tool: Bash
    Steps:
      1. Run: pre-commit install
      2. Make small change to gfm
      3. Run: git commit -m "test"
      4. Verify: Shellcheck runs automatically
    Expected Result: Hooks execute on commit
    Evidence: .sisyphus/evidence/task-10-precommit.txt
  ```

  **Commit**: YES
  - Message: `chore: add pre-commit hooks with shellcheck`
  - Files: `.pre-commit-config.yaml`

---

### Wave 3: CI/CD (After Wave 2)

- [ ] **Task 11: Create GitHub Actions CI Workflow**

  **What to do**:
  - Create `.github/workflows/ci.yml`
  - Test on Ubuntu and macOS matrix
  - Run test suite (all 14 tests)
  - Run shellcheck
  - Verify i18n works (English output)
  - Test installation scripts

  **Must NOT do**:
  - Do NOT only test on Ubuntu (must include macOS)
  - Do NOT ignore test failures

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` (CI/CD infrastructure)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 12, 13, 14, 15)
  - **Blocks**: Tasks 20, 25
  - **Blocked By**: Tasks 4, 6, 7

  **References**:
  - GitHub Actions docs: https://docs.github.com/en/actions
  - Example workflow for bash projects

  **Acceptance Criteria**:
  - [ ] CI passes on Ubuntu
  - [ ] CI passes on macOS
  - [ ] All 14 tests pass in CI
  - [ ] Shellcheck passes in CI

  **QA Scenarios**:

  ```
  Scenario: CI workflow passes
    Tool: GitHub Actions
    Steps:
      1. Push to any branch
      2. Check Actions tab
      3. Verify: CI workflow runs
      4. Verify: All jobs green
    Expected Result: CI passes on both Ubuntu and macOS
    Evidence: Screenshot of green CI run
  ```

  **Commit**: YES
  - Message: `ci: add GitHub Actions CI workflow`
  - Files: `.github/workflows/ci.yml`

---

- [ ] **Task 12: Create GitHub Actions Release Workflow**

  **What to do**:
  - Create `.github/workflows/release.yml`
  - Trigger on version tag push (v*)
  - Create GitHub Release with artifacts
  - Attach signed checksums
  - Generate release notes from CHANGELOG

  **Must NOT do**:
  - Do NOT create releases on every push (only on tags)
  - Do NOT release without passing CI

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` (release automation)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 11, 13, 14, 15)
  - **Blocks**: Task 20
  - **Blocked By**: Task 11

  **Acceptance Criteria**:
  - [ ] Push tag v2.0.0 creates release
  - [ ] Release contains signed artifacts
  - [ ] Release notes generated from CHANGELOG

  **QA Scenarios**:

  ```
  Scenario: Release workflow
    Tool: GitHub Actions
    Steps:
      1. Push tag: git tag v2.0.0 && git push origin v2.0.0
      2. Check Actions tab for release workflow
      3. Verify: Release created with artifacts
    Expected Result: Automated release with signed checksums
    Evidence: Link to GitHub release page
  ```

  **Commit**: YES
  - Message: `ci: add automated release workflow`
  - Files: `.github/workflows/release.yml`

---

- [ ] **Task 13: Create GitHub Actions Security Scan Workflow**

  **What to do**:
  - Create `.github/workflows/security.yml`
  - Run CodeQL analysis
  - Run Trivy vulnerability scan
  - Run on PRs and daily schedule
  - Block merge on critical findings

  **Must NOT do**:
  - Do NOT ignore security warnings
  - Do NOT run only on main branch (must scan PRs)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` (security automation)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 11, 12, 14, 15)
  - **Blocks**: None
  - **Blocked By**: Task 1

  **Acceptance Criteria**:
  - [ ] Security workflow runs on PRs
  - [ ] CodeQL analysis completes
  - [ ] No critical vulnerabilities in scan

  **QA Scenarios**:

  ```
  Scenario: Security scan
    Tool: GitHub Actions
    Steps:
      1. Create PR with any change
      2. Verify: Security workflow triggers
      3. Check: CodeQL analysis runs
    Expected Result: Security scan completes without critical issues
    Evidence: Screenshot of security scan results
  ```

  **Commit**: YES
  - Message: `ci: add security scanning with CodeQL`
  - Files: `.github/workflows/security.yml`

---

- [ ] **Task 14: Add CodeQL Analysis**

  **What to do**:
  - Configure CodeQL for bash/shell analysis
  - Add to security workflow
  - Customize queries for shell-specific issues
  - Document any ignored findings

  **Must NOT do**:
  - Do NOT disable CodeQL (required for professional project)

  **Recommended Agent Profile**:
  - **Category**: `quick` (configuration)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Blocked By**: Task 1
  - **Blocks**: None

  **Acceptance Criteria**:
  - [ ] CodeQL workflow runs successfully
  - [ ] No shell injection alerts

  **Commit**: YES
  - Message: `ci: add CodeQL analysis for shell scripts`
  - Files: `.github/workflows/security.yml` (or separate file)

---

- [ ] **Task 15: Create Issue and PR Templates**

  **What to do**:
  - Create `.github/ISSUE_TEMPLATE/bug_report.md`
  - Create `.github/ISSUE_TEMPLATE/feature_request.md`
  - Create `.github/PULL_REQUEST_TEMPLATE.md`
  - Add labels configuration

  **Must NOT do**:
  - Do NOT use complex templates (keep it simple)

  **Recommended Agent Profile**:
  - **Category**: `writing` (documentation)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Blocks**: None

  **Acceptance Criteria**:
  - [ ] Issue templates appear when creating new issue
  - [ ] PR template appears when creating PR

  **QA Scenarios**:

  ```
  Scenario: Issue templates
    Tool: GitHub web UI
    Steps:
      1. Go to GitHub repo → Issues → New
      2. Verify: Templates shown (Bug Report, Feature Request)
    Expected Result: Templates available
    Evidence: Screenshot of issue creation page
  ```

  **Commit**: YES
  - Message: `docs: add issue and PR templates`
  - Files: `.github/ISSUE_TEMPLATE/*`, `.github/PULL_REQUEST_TEMPLATE.md`

---

### Wave 4: Distribution (After Wave 3)

- [ ] **Task 16: Create Shell Completions (bash, zsh, fish)**

  **What to do**:
  - Create `completions/gfm.bash`
  - Create `completions/gfm.zsh`
  - Create `completions/gfm.fish`
  - Install completions in appropriate system locations
  - Document completion setup

  **Must NOT do**:
  - Do NOT require manual sourcing (use standard paths)

  **Recommended Agent Profile**:
  - **Category**: `quick` (scripting)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 17, 18, 19, 20)
  - **Blocks**: Task 17
  - **Blocked By**: Task 6 (i18n strings needed)

  **Acceptance Criteria**:
  - [ ] `gfm <TAB>` shows completions in bash
  - [ ] `gfm <TAB>` shows completions in zsh
  - [ ] Completions installed to standard paths

  **QA Scenarios**:

  ```
  Scenario: Bash completions
    Tool: Bash
    Steps:
      1. Install completions
      2. Run: gfm <TAB><TAB>
    Expected Result: Shows available commands (bug, fix, check, etc.)
    Evidence: .sisyphus/evidence/task-16-completions.txt
  ```

  **Commit**: YES
  - Message: `feat: add shell completions for bash, zsh, fish`
  - Files: `completions/gfm.bash`, `completions/gfm.zsh`, `completions/gfm.fish`

---

- [ ] **Task 17: Create Man Page**

  **What to do**:
  - Create `man/gfm.1` (troff format)
  - Include all commands and options
  - Include examples
  - Install to `/usr/local/share/man/man1/`

  **Must NOT do**:
  - Do NOT use external tools like ronn (pure troff)

  **Recommended Agent Profile**:
  - **Category**: `writing` (documentation)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 16, 18, 19, 20)
  - **Blocks**: Task 21
  - **Blocked By**: Task 6

  **Acceptance Criteria**:
  - [ ] `man gfm` displays manual page
  - [ ] All commands documented
  - [ ] Examples included

  **QA Scenarios**:

  ```
  Scenario: Man page works
    Tool: man
    Steps:
      1. Run: man ./man/gfm.1
      2. Verify: Displays formatted manual
    Expected Result: Professional man page displayed
    Evidence: .sisyphus/evidence/task-17-manpage.txt
  ```

  **Commit**: YES
  - Message: `docs: add man page for gfm`
  - Files: `man/gfm.1`

---

- [ ] **Task 18: Create Homebrew Formula**

  **What to do**:
  - Create `Formula/gfm.rb` (Homebrew formula)
  - Formula installs gfm, detector script, completions, man page
  - Test with `brew install --build-from-source ./Formula/gfm.rb`
  - Prepare for Homebrew/core submission

  **Must NOT do**:
  - Do NOT submit to Homebrew until v2.0.0 is released
  - Do NOT use HEAD-only formula (must use releases)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` (packaging)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 16, 17, 19, 20)
  - **Blocks**: Task 19
  - **Blocked By**: Tasks 3, 12

  **Acceptance Criteria**:
  - [ ] `brew install --build-from-source ./Formula/gfm.rb` works
  - [ ] `gfm --version` works after install
  - [ ] Completions installed
  - [ ] Man page installed

  **QA Scenarios**:

  ```
  Scenario: Homebrew install
    Tool: Homebrew
    Steps:
      1. Run: brew install --build-from-source ./Formula/gfm.rb
      2. Run: gfm --version
      3. Run: man gfm
    Expected Result: Installed and working via Homebrew
    Evidence: .sisyphus/evidence/task-18-homebrew.txt
  ```

  **Commit**: YES
  - Message: `dist: add Homebrew formula`
  - Files: `Formula/gfm.rb`

---

- [ ] **Task 19: Update install.sh with Signature Verification**

  **What to do**:
  - Add checksum verification for downloaded files
  - Add GPG signature verification option
  - Download from GitHub releases (not raw main branch)
  - Provide fallback for systems without gpg
  - Document verification process

  **Must NOT do**:
  - Do NOT use `curl | bash` without verification
  - Do NOT download from mutable sources (main branch)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` (security-critical)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 16, 17, 18, 20)
  - **Blocks**: Task 20
  - **Blocked By**: Task 12

  **Acceptance Criteria**:
  - [ ] install.sh downloads from GitHub releases
  - [ ] install.sh verifies checksums
  - [ ] install.sh warns if GPG not available (optional verification)

  **QA Scenarios**:

  ```
  Scenario: Secure installation
    Tool: Bash
    Steps:
      1. Run: ./install.sh
      2. Verify: Downloads from releases, not main branch
      3. Verify: Checksum verification occurs
    Expected Result: Secure installation with verification
    Evidence: .sisyphus/evidence/task-19-install.txt
  ```

  **Commit**: YES
  - Message: `security: add checksum verification to install.sh`
  - Files: `install.sh`

---

- [ ] **Task 20: Create Release Automation**

  **What to do**:
  - Create script to bump version across all files
  - Create script to generate release artifacts
  - Integrate with GitHub Actions release workflow
  - Generate signed checksums (SHA256)
  - Document release process

  **Must NOT do**:
  - Do NOT manually edit version in multiple places
  - Do NOT release without signed artifacts

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` (automation)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 16, 17, 18, 19)
  - **Blocks**: Task F4
  - **Blocked By**: Tasks 12, 18, 19

  **Acceptance Criteria**:
  - [ ] Release script bumps VERSION and updates all files
  - [ ] Release creates signed SHA256 checksums
  - [ ] Release process documented

  **QA Scenarios**:

  ```
  Scenario: Release automation
    Tool: Bash
    Steps:
      1. Run: ./scripts/release.sh 2.1.0
      2. Verify: VERSION file updated
      3. Verify: Tag created
      4. Verify: Checksums generated
    Expected Result: Fully automated release
    Evidence: .sisyphus/evidence/task-20-release.txt
  ```

  **Commit**: YES
  - Message: `ci: add release automation scripts`
  - Files: `scripts/release.sh`

---

### Wave 5: Documentation & Polish (After Wave 4)

- [ ] **Task 21: Create CHANGELOG.md**

  **What to do**:
  - Create CHANGELOG.md following Keep a Changelog format
  - Document all changes for v2.0.0
  - Document breaking changes
  - Link to GitHub compare pages

  **Must NOT do**:
  - Do NOT use GitHub releases as changelog (must have file in repo)

  **Recommended Agent Profile**:
  - **Category**: `writing` (documentation)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 22, 23, 24, 25)
  - **Blocks**: Task F4
  - **Blocked By**: Tasks 6, 17

  **Acceptance Criteria**:
  - [ ] CHANGELOG.md exists and follows Keep a Changelog format
  - [ ] v2.0.0 changes documented
  - [ ] Breaking changes clearly marked

  **QA Scenarios**:

  ```
  Scenario: Changelog format
    Tool: Markdown viewer
    Steps:
      1. Open CHANGELOG.md
      2. Verify: Follows Keep a Changelog format
      3. Verify: v2.0.0 section exists
    Expected Result: Professional changelog
    Evidence: .sisyphus/evidence/task-21-changelog.md
  ```

  **Commit**: YES
  - Message: `docs: add CHANGELOG.md`
  - Files: `CHANGELOG.md`

---

- [ ] **Task 22: Create SECURITY.md**

  **What to do**:
  - Create SECURITY.md
  - Document vulnerability reporting process
  - Provide contact email
  - Document supported versions
  - Document security update policy

  **Must NOT do**:
  - Do NOT use personal email (use project email or GitHub security advisories)

  **Recommended Agent Profile**:
  - **Category**: `writing` (documentation)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 21, 23, 24, 25)
  - **Blocks**: Task F4
  - **Blocked By**: Task 1

  **Acceptance Criteria**:
  - [ ] SECURITY.md exists
  - [ ] Vulnerability reporting process documented
  - [ ] Supported versions documented

  **QA Scenarios**:

  ```
  Scenario: Security policy
    Tool: GitHub web UI
    Steps:
      1. Go to Security tab
      2. Verify: SECURITY.md appears
      3. Verify: Reporting process clear
    Expected Result: Security policy in place
    Evidence: Screenshot of security tab
  ```

  **Commit**: YES
  - Message: `docs: add SECURITY.md with vulnerability reporting process`
  - Files: `SECURITY.md`

---

- [ ] **Task 23: Update README.md with New Install Instructions**

  **What to do**:
  - Update installation section with Homebrew
  - Update installation section with signed release method
  - Add badges (CI status, version, license)
  - Add i18n documentation
  - Add contributing section

  **Must NOT do**:
  - Do NOT remove manual install option (keep as fallback)
  - Do NOT make `curl | bash` the primary method

  **Recommended Agent Profile**:
  - **Category**: `writing` (documentation)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 21, 22, 24, 25)
  - **Blocks**: Task F4
  - **Blocked By**: Tasks 6, 18, 19

  **Acceptance Criteria**:
  - [ ] README shows Homebrew install as primary method
  - [ ] README shows signed release install method
  - [ ] Badges display correctly
  - [ ] i18n usage documented

  **QA Scenarios**:

  ```
  Scenario: README accuracy
    Tool: Markdown viewer
    Steps:
      1. View README.md
      2. Verify: Homebrew instructions present
      3. Verify: Badges render correctly
    Expected Result: Professional README
    Evidence: Screenshot of README
  ```

  **Commit**: YES
  - Message: `docs: update README with new install methods and badges`
  - Files: `README.md`

---

- [ ] **Task 24: Add Badges and Shields**

  **What to do**:
  - Add CI status badge
  - Add version badge (shields.io)
  - Add license badge
  - Add security scan badge

  **Must NOT do**:
  - Do NOT add broken badges (must work before release)

  **Recommended Agent Profile**:
  - **Category**: `quick` (configuration)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 21, 22, 23, 25)
  - **Blocks**: None
  - **Blocked By**: Task 11

  **Acceptance Criteria**:
  - [ ] Badges display correctly on GitHub
  - [ ] All badge links work

  **QA Scenarios**:

  ```
  Scenario: Badges render
    Tool: GitHub web UI
    Steps:
      1. View repo on GitHub
      2. Verify: All badges display
      3. Click badges to verify links
    Expected Result: Badges work
    Evidence: Screenshot of badges
  ```

  **Commit**: YES (can group with Task 23)

---

- [ ] **Task 25: Final Integration Test**

  **What to do**:
  - Run full test suite on clean environment
  - Test installation via all methods (Homebrew, install.sh, manual)
  - Test on both Linux and macOS
  - Verify all commands work
  - Verify i18n works
  - Verify completions work

  **Must NOT do**:
  - Do NOT skip any test scenarios

  **Recommended Agent Profile**:
  - **Category**: `deep` (comprehensive testing)
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO (final validation)
  - **Blocks**: Tasks F1-F4
  - **Blocked By**: Tasks 11, 16, 17, 18

  **Acceptance Criteria**:
  - [ ] All 14 tests pass
  - [ ] Installation works via Homebrew
  - [ ] Installation works via install.sh
  - [ ] English interface works
  - [ ] Completions work
  - [ ] Man page works

  **QA Scenarios**:

  ```
  Scenario: Full integration test
    Tool: Multiple (bash, brew, man)
    Steps:
      1. Fresh VM/container
      2. Install via Homebrew
      3. Run: gfm bug "Test integration"
      4. Run: gfm fix BUG-XXXX
      5. Run: gfm check
      6. Run: man gfm
    Expected Result: Everything works end-to-end
    Evidence: .sisyphus/evidence/task-25-integration.txt
  ```

  **Commit**: NO (testing only)

---

## Final Verification Wave (After ALL Tasks)

- [ ] **Task F1: Security Audit (Oracle)**

  **What to do**:
  - Review all security fixes from Task 1
  - Verify no new injection vulnerabilities introduced
  - Run security scan (CodeQL, Trivy)
  - Verify input sanitization works
  - Check temp file handling

  **Acceptance Criteria**:
  - [ ] No CodeQL security alerts
  - [ ] No Trivy critical vulnerabilities
  - [ ] Manual injection tests pass

  **Output**: `Security Audit: PASS / FAIL`

---

- [ ] **Task F2: Cross-Platform QA (unspecified-high)**

  **What to do**:
  - Test on Ubuntu 22.04
  - Test on macOS (latest)
  - Test installation methods
  - Test all commands
  - Verify no platform-specific failures

  **Acceptance Criteria**:
  - [ ] Works on Ubuntu
  - [ ] Works on macOS
  - [ ] CI passes on both platforms

  **Output**: `Cross-Platform: PASS / FAIL`

---

- [ ] **Task F3: Documentation Review (writing)**

  **What to do**:
  - Review all documentation for accuracy
  - Check for broken links
  - Verify installation instructions work
  - Check for typos

  **Acceptance Criteria**:
  - [ ] All docs accurate
  - [ ] No broken links
  - [ ] Installation instructions tested

  **Output**: `Documentation: PASS / FAIL`

---

- [ ] **Task F4: Release Preparation (deep)**

  **What to do**:
  - Tag v2.0.0
  - Create GitHub Release
  - Attach signed artifacts
  - Update Homebrew formula
  - Announce release

  **Acceptance Criteria**:
  - [ ] v2.0.0 tag created
  - [ ] GitHub Release published
  - [ ] Artifacts signed
  - [ ] Homebrew formula submitted (or ready for submission)

  **Output**: `Release: v2.0.0 PUBLISHED`

---

## Commit Strategy

- **Wave 1**: Individual commits (security fixes separate)
- **Wave 2**: Individual commits (i18n separate)
- **Wave 3**: Individual commits per workflow
- **Wave 4**: Individual commits (completions, man page, Homebrew)
- **Wave 5**: Documentation commits grouped by file
- **Final**: Tag commit v2.0.0

Commit message format: `type(scope): description` following conventional commits.

---

## Success Criteria

### Verification Commands
```bash
# Security
shellcheck --severity=warning gfm scripts/*.sh install*.sh
# Expected: Exit code 0

# Tests
bash tests/run-detector-tests.sh
# Expected: Summary: PASS=14 FAIL=0

# i18n
GFM_LANG=en ./gfm help | grep -i "mark a bug"
# Expected: English text

# Version sync
grep '^VERSION=' gfm | grep "$(cat VERSION)"
# Expected: Match

# Installation (macOS with Homebrew)
brew install --build-from-source ./Formula/gfm.rb
gfm --version
# Expected: Git Fix Manager v2.0.0
```

### Final Checklist
- [ ] All shellcheck warnings resolved
- [ ] All 14 tests passing
- [ ] GitHub Actions CI green
- [ ] English interface default
- [ ] Version synchronized
- [ ] Homebrew install works
- [ ] Signed release artifacts
- [ ] Security audit passed
- [ ] Documentation complete
- [ ] v2.0.0 released

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Security audit reveals new issues | High | Allocate buffer time in Wave 1 |
| Homebrew formula rejected | Medium | Have install.sh fallback ready |
| macOS compatibility issues | Medium | Test early and often |
| i18n complexity underestimated | Medium | Start with simple variable approach |
| Timeline slips | Medium | Prioritize Must Haves, defer Nice-to-Haves |

---

## Notes

- **Dependencies**: All tasks use only bash and standard Unix tools
- **External services**: GitHub Actions, Homebrew (for distribution)
- **Backward compatibility**: Must maintain existing command API
- **Breaking changes**: Allowed for v2.0.0 but must be documented
