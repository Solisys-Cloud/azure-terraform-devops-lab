# Git workflow for Solisys-Cloud labs

**Audience:** Contributors and readers learning Git-based infrastructure workflows.

## Why we use branches and pull requests

Changes should be reviewed before they are merged into `main`. This provides a change history, a place to discuss design choices, and an opportunity for CI validation.

## Suggested workflow

1. Start from an up-to-date `main`.
2. Create a descriptive branch such as `feature/lab01-network` or `docs/lab01-learning-foundations`.
3. Add or modify documentation and code in that branch.
4. Commit small, meaningful changes.
5. Push the branch to GitHub.
6. Open a pull request targeting `main`.
7. Review the diff and CI results, then merge when approved.

**The first lab intentionally introduces this workflow before adding deployment automation.**

## Important Terraform Git rules

- Commit: `*.tf`, `README.md`, non-sensitive examples, and `.terraform.lock.hcl` after running init.
- Do not commit: `.terraform/`, `*.tfstate*`, actual `*.tfvars`, plan outputs, `.env`, credentials, or private keys.
- Confirm which files will be committed using `git status` and `git diff --cached`.
- A `.gitignore` protects **untracked** files only. It does not remove sensitive data already committed. If secrets are exposed, revoke and rotate them immediately.
- For future Azure deployments, require plan review and an explicit approval before `terraform apply`.

## Beginner checklist

- [ ] Changes committed to a feature or documentation branch
- [ ] No secrets or state files in the diff
- [ ] README and diagrams accurately describe the code
- [ ] CI validations are green, when available
- [ ] Pull request reviewed before merge
