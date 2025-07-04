---
sidebar_position: 4
sidebar_label: Prompts
---

# Prompts

## Sending Prompts

### In the REPL

To send a prompt in the [REPL](../repl.md), just type your prompt and press enter.

You can also use `\multi` to enable multi-line mode. This will cause enter to produce line breaks. In multi-line mode, you can send your prompt with `\send`.

If you want to pass in a file as a prompt in the REPL, you can use the `\run` command with a relative file path:

```
\run src/components/foobars-form.tsx
```

### With the CLI

To send a prompt with the CLI, use the `planto tell` command for a task, or the `planto chat` command to brainstorm or ask questions.

You can pass it in as a file with the `--file/-f` flag:

```bash
planto tell -f prompt.txt
planto chat -f prompt.txt
```

Write it in vim:

```bash
planto tell # tell with no arguments opens vim so you can write your prompt there
planto chat # chat with no arguments does the same
```

Pass it inline (use enter for line breaks):

```bash
planto tell "add a new line chart showing the number of foobars over time to components/charts.tsx"
planto chat "where's the database connection logic in this project?"
```

You can also pipe in the results of another command:

```bash
git diff | planto tell
git diff | planto chat
```

When you pipe in results like this, you can also supply an inline string to give a label or additional context to the results:

```bash
git diff | planto tell "'git diff' output"
```

## Plan Stream TUI

After you send a prompt with the REPL, `planto tell`, or `planto chat`, you'll see the plan stream TUI. The model's responses are streamed here. You'll see several hotkeys listed along the bottom row that allow you to stop the plan (s), send the plan to the background (b), scroll/page the streamed text, or jump to the beginning or end of the stream. If you're a vim user, you'll notice Planto's scrolling hotkeys are the same as vim's.

Note that scrolling the terminal window itself won't work while you're in the stream TUI. Use the scroll hotkeys instead.

## Task Prompts

When you give Planto a task, it will first break down the task into steps, then it will proceed to implement each step in code. Planto will automatically continue sending model requests until the task is determined to be complete.

## Chat Prompts

If you want to ask Planto questions or chat without generating files or making changes, use the `planto chat` command instead of `planto tell`.

```bash
planto chat "explain every function in lib/math.ts"
```

Planto will reply with just a single response, won't create or update any files, and won't automatically continue.

`planto chat` has the same options for passing in a prompt as `planto tell`. You can pass a string inline, give it a file with `--file/-f`, type the prompt in vim by running `planto chat` with no arguments, or pipe in the results of another command.

### In the REPL

In the REPL, you can control whether prompts are sent to `planto tell` or `planto chat` under the hood by toggling `chat mode` with `\chat (\ch)` or `\tell (\t)`.

## Stopping and Continuing

When using `planto tell`, you can prevent Planto from automatically continuing for multiple responses by passing the `--stop/-s` flag:

```bash
planto tell -s "write tests for the charting helpers in lib/chart-helpers.ts"
```

Planto will then reply with just a single response. From there, you can continue if desired with the `continue` command. Like `tell`, `continue` can also accept a `--stop/-s` flag. Without the `--stop/-s` flag, `continue` will also cause Planto to continue automatically until the task is done. If you pass the `--stop/-s` flag, it will continue for just one more response.

```bash
planto continue -s
```

Apart from `--stop/-s` Planto's plan stream TUI also has an `s` hotkey that allows you to immediately stop a plan.

You can also stop a plan from automatically continuing by setting the `auto-continue` config option to `false` in a plan's [configuration](./configuration.md):

```bash
planto set-config auto-continue false
planto set-config default auto-continue false # set the default config's auto-continue to false for all new plans
```

or by setting the `auto-mode` ([autonomy level](./autonomy.md)) to `none`:

```bash
planto set-auto none
planto set-default-auto none # set the default auto-mode to none for all new plans
```

## Background Tasks

By default, `planto tell` opens the plan stream TUI and streams Planto's response(s) there, but you can also pass the `--bg` flag to run a task in the background instead.

You can learn more about using and interacting with background tasks [here](./background-tasks.md).

## Keeping Context Updated

When you send a prompt, whether through `planto tell` or `planto chat`, Planto will check whether the content of any files, directory layouts, or URLs you've loaded into [context](./context-management.md) have changed. If so, you'll need to update the context before continuing.

By default, Planto will update any outdated context automatically, but if you'd rather approve these updates, you can set the `auto-update-context` config option to `false`:

```bash
planto set-config auto-update-context false
planto set-config default auto-update-context false # set the default config's auto-update-context to false for all new plans
```

or you can set the `auto-mode` to `basic` or `none`:

```bash
planto set-auto basic
planto set-auto none
```

## Building Files

As Planto implements your task, files it creates or updates will appear in the `Building Plan` section of the plan stream TUI. Planto will **build** all changes proposed by the plan into a set of pending changesets for each affected file.

By default, these changes initially **will not** be directly applied to your project files. Instead, they will be **pending** in Planto's version-controlled sandbox.

This allows you to review the proposed changes or continue iterating and accumulating more changes. You can view the pending changes with `planto diff` (for git diff format in the terminal) or `planto diff --ui` (to view them in a local browser UI). Once you're happy with the changes, you can apply them to your project files with `planto apply`.

- [Learn more about reviewing changes.](./reviewing-changes.md)
- [Learn more about version control.](./version-control.md)

### Full auto mode

An important caveat to the above: if you set the `auto-mode` to `full`, Planto _will_ automatically apply the changes to your project files,

### Skipping builds / `planto build`

You can skip building files when you send a prompt by passing the `--no-build` flag to `planto tell` or `planto continue`. This can be useful if you want to ensure that a plan is on the right track before building files.

```bash
planto tell "implement sign up and sign in forms in src/components" --no-build
```

You can later build any changes that were implemented in the plan with the `planto build` command:

```bash
planto build
```

This will show a smaller version of the plan stream TUI that only includes the `Building Plan` section.

Like full plan streams, build streams can be stopped with the `s` hotkey or sent to the background with the `b` hotkey. They can also be run fully in the background with the `--bg` flag:

```bash
planto build --bg
```

There's one more thing to keep in mind about builds. If you send a prompt with the `--no-build` flag:

```bash
planto tell "implement a forgot password email in src/emails" --no-build
```

Then you later send _another_ prompt with `planto tell` or continue the plan with `planto continue` and you _don't_ include the `--no-build` flag, any changes that were implemented previously but weren't built will immediately start building when the plan stream begins.

```bash
planto tell "now implement the UI portion of the forgot password flow"
# the above will start building the changes proposed in the earlier prompt that was passed --no-build
```

## Automatically Applying Changes

If you want Planto to _automatically_ apply changes when a plan is complete, you can pass the `--apply/-a` flag to `planto tell`, `planto continue`, or `planto build`:

```bash
planto tell "add a new route for updating notification settings to src/routes.ts" --apply
```

The `--apply/-a` flag will also automatically update context if needed, just as the `--yes/-y` flag does.

When passing `--apply/-a`, you can also use the `--commit/-c` flag to commit the changes to git with an auto-generated commit message. This will only commit the specific changes that were made by the plan. Any other changes in your git repository, staged or unstaged, will remain as they are.

```bash
planto tell "add a new route for updating notification settings to src/routes.ts" --apply --commit
```

## Iterating on a Plan

If you send a prompt:

```bash
planto tell "implement a fully working and production-ready tic tac toe game, including a computer-controlled AI, in html, css, and javascript"
```

And then you want to iterate on it, whether that's to add more functionality or correct something that went off track, you have a couple options.

### Continue the convo

The most straightforward way to continue iterating is to simply send another `planto tell` command:

```bash
planto tell "I plan to seek VC funding for this game, so please implement a dark mode toggle and give all buttons subtle gradient fills"
```

This is generally a good approach when you're happy with the current plan and want to extend it to add more functionality.

Note, you can view the full conversation history with the `planto convo` command:

```bash
planto convo
```

### Rewind and iterate

Another option is to use Planto's [version control](./version-control.md) features to rewind to the point just before your prompt was sent and then update it before sending the prompt again.

You can use `planto log` to see the plan's history and determine which step to rewind to, then `planto rewind` with the appropriate hash to rewind to that step:

```bash
planto log # see the history
planto rewind accfe9 # rewind to right before your prompt
```

This approach works well in conjunction with **prompt files**. You write your prompts in files somewhere in your codebase, then pass those to `planto tell` using the `--file/-f` flag:

```bash
planto tell -f prompts/tic-tac-toe.txt
```

This makes it easy to continuously iterate on your prompt using `planto rewind` and `planto tell` until you get a result that you're happy with.

### Which is better?

There's not necessarily one right answer on whether to use an ongoing conversation or the `rewind` approach with prompt files for iteration. Here are a few things to consider when making the choice:

- Bad results tend to beget more bad results. Rewinding and iterating on the prompt is often more effective for correcting a wayward task than continuing to send more `tell` commands. Even if you are specifically prompting the model to _correct_ a problem, having the wrong approach in its context will tend to bias it toward additional errors. Using `rewind` to the give the model a clean slate can work better in these scenarios.

- Iterating on a prompt file with the `rewind` approach until you find your way to an effective prompt has another benefit: you can keep the final version of the prompt that produced a given set of changes right alongside the changes themselves in your codebase. This can be helpful for other developers (or your future self) if you want to revisit a task later.

- A downside of the `rewind` approach is that it can involve re-running early steps of a plan over and over, which can be **a lot** more expensive than iterating with additional `tell` commands.
