---
sidebar_position: 1
sidebar_label: Plans
---

# Plans

A **plan** in Planto is similar to a conversation in ChatGPT or Claude. It might only include a single prompt and model response that executes one small task, or it could represent a long back and forth with the model that generates dozens of files and builds a whole feature or an entire project.

A plan includes:

- Any [context](./context-management.md) that you or the model have loaded.
- Your [conversation](./conversations.md) with the model.
- Any [pending changes](./reviewing-changes.md) that have been accumulated during the course of the conversation.

Plans support [version control](./version-control.md) and [branches](./branches.md).

## Creating a New Plan

First `cd` into your **project's directory.** Make a new directory first with `mkdir your-project-dir` if you're starting on a new project.

```bash
cd your-project-dir
```

### REPL

To start a new plan with the REPL, just run:

```bash
planto
```

If you haven't created a new plan in this directory previously, a plan will automatically be created for you when the REPL starts.

If already have a plan loaded in the REPL (you can check with `\current`), you can start a new plan with `\new`.

### CLI

You can create a new plan through the CLI with `planto new`.

```bash
planto new
```

## Plan Names and Drafts

When you create a plan, Planto will automatically name your plan after you send the first prompt, but you can also give it a name up front.

```bash
planto new -n foo-adapters-component
```

If you don't give your plan a name up front, it will be named `draft` until you send an initial prompt. To keep things tidy, you can only have one active plan named `draft`. If you create a new draft plan, any existing draft plan will be removed.

## Listing Plans

When you have multiple plans, you can list them with the `plans` command.

```bash
planto plans
```

## The Current Plan

It's important to know what the **current plan** is for any given directory, since most Planto commands are executed against that plan.

To check the current plan:

```bash
planto current
```

You can change the current plan with the `cd` command:

```
planto cd # select from a list of plans
planto cd some-other-plan # cd to a plan by name
planto cd 2 # cd to a plan by number in the `planto plans` list
```

## Deleting Plans

You can delete a plan with the `delete-plan` command:

```bash
planto delete-plan # select from a list of plans to delete
planto delete-plan some-plan # delete a plan by name
planto delete-plan 4 # delete a plan by number in the `planto plans` list
```

## Archiving Plans

You can archive plans you want to keep around but aren't currently working on with the `archive` command. You can see archived plans in the current directory with `plans --archived`. You can unarchive a plan with the `unarchive` command.

```bash
planto archive # select from a list of plans to archive
planto archive some-plan # archive a plan by name
planto archive 2 # archive a plan by number in the `planto plans` list

planto unarchive # select from a list of archived plans to unarchive
planto unarchive some-plan # unarchive a plan by name
planto unarchive 2 # unarchive a plan by number in the `planto plans --archived` list
```

## .planto Directory

When you run `planto` (for a REPL) or `planto new` for the first time in any directory, Planto will create a `.planto` directory there for light project-level config.

If multiple people are using Planto with the same project, you should either:

- **Commit** the `.planto` directory and get everyone into the same [org](./orgs.md) in Planto.
- Put `.planto/` in `.gitignore`

## Project Directories

So far, we've assumed you're running `planto` or `planto new` to create plans in your project's root directory. While that is the most common use case, it can be useful to create plans in subdirectories of your project too.

That's because context file paths in Planto are specified relative to the directory where the plan was created. So if you're working on a plan for just one part of your project, you might want to create the plan in a subdirectory in order to shorten paths when loading context or referencing files in your prompts.

Starting a plan (or REPL) in a subdirectory is also helpful when using [automatic context loading](./context-management.md#automatic-vs-manual) to limit the size of the project map and what files are available for the LLM to load.

It can also help with plan organization if you have a lot of plans.

When you run `planto plans`, in addition to showing you plans in the current directory, Planto will also show you plans in nearby parent directories or subdirectories. This helps you keep track of what plans you're working on and where they are in your project hierarchy. If you want to switch to a plan in a different directory, first `cd` into that directory, then run `planto cd` to select the plan.
