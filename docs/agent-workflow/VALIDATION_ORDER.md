# Validation Order

## Rule
Run the smallest validation that proves the current change is safe.
Escalate only when scope justifies it.

## Order
1. scripts/check-fast.sh
2. scripts/check-changed.sh
3. targeted smoke checks
4. scripts/check-full.sh

## Use check-fast when
- docs-only changes
- control-plane docs/adapters changed
- prompt/helper updates
- tiny non-runtime edits

## Use check-fast + check-changed when
- implementation files changed
- narrow bugfixes
- bounded Aider patch work

## Use full validation when
- runtime/config changed
- dependencies changed
- refactor crosses modules
- release is in scope
- risk is high
