# Cloud to Local Handoff

## Purpose
Make planning/implementation output reviewable before local verification and commit.

## Required handoff contents
- exact files changed
- intended outcome
- required validations
- known uncertainties
- out-of-scope items
- readiness for local verification

## Local verifier must do
- read HANDOFF.md
- read canonical workflow docs
- inspect git diff --stat
- inspect relevant diffs
- run validation in canonical order

## Commit gate
Commit/push only after validation passes and the diff is reviewed.
