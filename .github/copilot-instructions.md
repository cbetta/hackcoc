# Copilot code review instructions

Report only correctness, security, data-loss and permission problems. Skip style, naming, comment wording, formatting and test structure. Don't repeat a point that was already declined with a reason in the PR. If a finding wouldn't cause a bug or a leak, don't post it. Prefer one precise comment with the failing input over several general ones.

## Security checklist

Flag any of these:

- Secrets or tokens in logs, error messages or commits.
- Text written by other people (mail, messages, web pages) reaching a model unwrapped. mcp-hub wraps it in `<untrusted>`.
- One account's data reaching another account (the agents dashboard is multi-account).
- Personal data (mail, messages, health) in logs or error messages.
- A new route or action with no permission check.
- Workflow changes that give a branch or fork access to secrets (`pull_request_target`, broader `permissions`, secrets passed to unreviewed code).
