# Contributing

Ideas, bug reports, experiments, and pull requests are welcome. This is a portfolio prototype using synthetic failures. Please distinguish proposed improvements from behavior you have actually tested.

## Suggest an improvement or report a problem

Open a GitHub issue describing the testing problem, expected behavior, actual behavior, and a minimal synthetic payload. Include your n8n version and sanitized error details when relevant. Never include credentials, private URLs, customer data, or credential exports.

For a larger change, open an issue first so we can discuss scope.

## Develop a contribution

1. Fork the repository and create a branch for your change.
2. Configure your own sandbox credentials and destinations.
3. Make a focused change and update the relevant documentation.
4. For workflow changes, check that the JSON imports and verify affected routes in your own n8n instance.
5. Open a pull request describing the problem, the change, observed results, and any remaining limitations.

Remove credential bindings, account resource IDs, pinned data, and instance metadata from exported workflows before submitting. Preserve required placeholders and include only synthetic test data.

## Useful starting points

- Add tests that verify classification and destination creation rather than HTTP acceptance alone.
- Resolve classification conflicts and define priority separately from severity.
- Add idempotency and duplicate-ticket detection.
- Complete High-priority fan-out and isolate destination failures.
- Add CI runner adapters and representative synthetic failure scenarios.
- Prototype the proposed cloud architecture and document measured results.
- Improve setup instructions and troubleshooting.

A good first contribution can be a clearer setup step, a synthetic edge case, or a reproducible issue report. No live account access is required to suggest improvements.

## Review expectations

Explain how you verified the change. Do not claim production readiness, accuracy, latency, or cost improvements without evidence. Keep contributions small enough to review and discuss alternative approaches respectfully.

See the repository's license status before redistributing or reusing its contents. This guide does not grant a separate license.
