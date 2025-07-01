---
sidebar_position: 5
sidebar_label: Pending Changes
---

# Pending Changes

When you give Planto a task, by default the changes aren't applied directly to your project files. Instead, they are accumulated in Planto's version-controlled **sandbox** so that you can review them first.

## Review Menu

Once Planto has finished with a task, you'll see a review menu with several hotkey options. These hotkeys act as shortcuts for the commands described below.

## Viewing Changes

### `planto diff` / `planto diff --ui`

When Planto has finished with your task, you can review the proposed changes with the `planto diff` command, which shows them in `git diff` format:

```bash
planto diff
```

`--plain/-p`: Outputs the diff in plain text with no ANSI codes.

You can also view the changes in a local browser UI with the `planto diff --ui` command:

```bash
planto diff --ui
```

The UI view offers additional options:

- `--side-by-side/-s`: Show diffs in side-by-side view
- `--line-by-line/-l`: Show diffs in line-by-line view (default)

## Rejecting Files

If the plan's changes were applied incorrectly to a file, or you don't want to apply them for another reason, you can either [apply the changes](#applying-changes) and then fix the problems manually, _or_ you can reject the updates to that file and then make the proposed changes yourself manually.

To reject changes to a file (or multiple files), you can run `planto reject`. You'll be prompted to select which files to reject.

```bash
planto reject # select files to reject
```

You can reject _all_ currently pending files by passing the `--all` flag to the reject command, or you can pass a list of specific files to reject:

```bash
planto reject --all
planto reject file1.ts file2.ts
```

If you rejected a file due to the changes being applied incorrectly, but you still want to use the code, either scroll up and copy the changes from the plan's output or run `planto convo` to output the full conversation and copy from there. Then apply the updates to that file yourself.

## Applying Changes

Once you're happy with the plan's changes, you can apply them to your project files with `planto apply`:

```bash
planto apply
```

### Apply Flags & Config

Planto v2 introduces several [new config settings and flags](./configuration.md) for the `apply` command that give you control over what happens after changes are applied.

### Command Execution & Debugging

After applying changes, Planto can automatically execute pending commands. This is useful for running tests, starting servers, or performing other actions that verify the changes work as expected.

If commands fail, the changes are rolled back. Depending on the autonomy level and config, Planto will then either attempt to debug automatically or prompt you with debugging options.

## Auto-Applying Changes

When `auto-apply` is enabled, Planto will automatically apply changes after a plan is complete without prompting or review. This is enabled at the `full` [autonomy level](./autonomy.md), and also during auto-debugging.

## Apply + Full Auto

You can also apply changes and debug in full auto mode with the `--full` flag:

```bash
planto apply --full
```

## Autonomy Matrix

| Setting       | None | Basic | Plus | Semi | Full |
| ------------- | ---- | ----- | ---- | ---- | ---- |
| `auto-apply`  | ❌   | ❌    | ❌   | ❌   | ✅   |
| `auto-exec`   | ❌   | ❌    | ❌   | ❌   | ✅   |
| `auto-debug`  | ❌   | ❌    | ❌   | ❌   | ✅   |
| `auto-commit` | ❌   | ❌    | ✅   | ✅   | ✅   |
