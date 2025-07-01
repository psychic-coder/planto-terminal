---
sidebar_position: 8
sidebar_label: Branches
---

# Branches

Branches in Planto allow you to easily try out multiple approaches to a task and see which gives you the best results. They work in conjunction with [version control](./version-control.md). Use cases include:

- Comparing different prompting strategies.
- Comparing results with different files in context.
- Comparing results with different models or model-settings.
- Using `planto rewind` without losing history (first check out a new branch, then rewind).

## Creating a Branch

To create a new branch, use the `planto checkout` command:

```bash
planto checkout new-branch
pdxd new-branch # alias
```

## Switching Branches

To switch to a different branch, also use the `planto checkout` command:

```bash
planto checkout existing-branch
```

## Listing Branches

To list all branches, use the `planto branches` command:

```bash
planto branches
```

## Deleting a Branch

To delete a branch, use the `planto delete-branch` command:

```bash
planto delete-branch branch-name
```
