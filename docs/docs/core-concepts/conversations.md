---
sidebar_position: 9
sidebar_label: Conversations
---

# Conversations

Each time you send a prompt to Planto or Planto responds, the plan's **conversation** is updated. Conversations are [version controlled](./version-control.md) and can be [branched](./branches.md).

## Conversation History

You can see the full conversation history with the `convo` command.

```bash
planto convo # show the full conversation history
```

You can output the conversation in plain text with no ANSI codes with the `--plain` or `-p` flag.

```bash
planto convo --plain
```

You can also show a specific message number or range of messages.

```bash
planto convo 1 # show the initial prompt
planto convo 1-5 # show messages 1 through 5
planto convo 2- # show messages 2 through the end of the conversation
```

## Conversation Summaries

Every time the AI model replies, Planto will summarize the conversation so far in the background and store the summary in case it's needed later. When the conversation size in tokens exceeds the model's limit, Planto will automatically replace some number of older messages with the corresponding summary. It will summarize as many messages as necessary to keep the conversation size under the limit.

Summaries are also used by the model as a form of working memory to keep track of the state of the plan—what's been implemented and what remains to be done.

You can see the latest summary with the `summary` command.

```bash
planto summary # show the latest conversation summary
```

As with the `convo` command, you can output the summary in plain text with no ANSI codes with the `--plain` or `-p` flag.

```bash
planto summary --plain
```
