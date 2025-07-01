---
sidebar_position: 1
sidebar_label: Cloud
---

# Planto Cloud

## Overview

Planto Cloud is the easiest and most reliable way to use Planto. You'll be prompted to start a trial when you launch the [REPL](../repl.md) with `planto` or create your first plan with `planto new`.

## Billing Modes

Planto Cloud has two billing modes:

### Integrated Models

- Use Planto credits to pay for AI models.
- No separate accounts or API keys are required.
- Credits are deducted at the model's price from OpenAI or OpenRouter.ai plus a small markup to cover credit card processing costs.
- Start with a $10 trial (includes $10 in credits).
- After the trial, you can upgrade to a paid plan for $45 per month—includes $20 in credits every month that never expire.

[Get started with Integrated Models Mode.](https://app.planto.ai/start?modelsMode=integrated)


### BYO API Key

- Use your own OpenAI and OpenRouter.ai accounts and API keys.
- Start with a free trial up to 10 plans and 20 model responses per plan.
- After the trial, you can upgrade to a paid plan for $30 per month.

[Get started with BYO API Key Mode.](https://app.planto.ai/start?modelsMode=byo)

## Billing Settings

Run `planto billing` in the terminal to bring up the billing settings page in your default browser, or go to [your Billing Settings page](https://app.planto.ai/settings/billing) (sign in if necessary).

Here you can switch billing modes, view your current plan, manage your billing details, pause or cancel your subscription and more.

### Integrated Models Mode

If you're using **Integrated Models Mode**, you can use the billing settings page to view your credits balance, purchase credits, and configure auto-recharge settings to automatically add credits to your account when your balance gets too low. You can also set a monthly budget and an email notification threshold.

### `usage` command

You can see your current balance and a report on recent usage with `planto usage` (`\usage` in the REPL):

```bash
planto usage
```

You can see a log of individual transactions that includes every model call with `planto usage --log`:

```bash
planto usage --log
```

In the Planto REPL, `usage` defaults to showing usage for the current REPL session. Otherwise, it defaults to showing usage for the day so far.

You can use the `--today` flag to show usage for the day so far. You can use the `--month` flag to show usage for the current billing month. You can use the `--plan` flag to show usage for the current plan.

```bash
planto usage --today # show usage for the day so far
planto usage --month # show usage for the current billing month
planto usage --plan # show usage for the current plan
```

You can use the `--debits` flag to show only debits in the log. You can use the `--purchases` flag to show only purchases in the log.

```bash
planto usage --log --debits --month # show only debits for the current billing month
planto usage --log --purchases --today # show only purchases for the day so far
```

## Privacy / Data Retention

Data you send to Planto Cloud is retained in order to debug and improve Planto. In the future, this data may also be used to train and fine-tune models to improve performance and reduce costs.

That said, if you delete your Planto Cloud account, all associated data will be removed within 14 days (this delay allows for debugging and backups).

Data sent to Planto Cloud may be shared with the following third parties:

- [OpenAI](https://openai.com) for OpenAI models when using Integrated Models Mode.
- [OpenRouter.ai](https://openrouter.ai/) for Anthropic, Google, and other non-OpenAI models when using Integrated Models Mode.
- [AWS](https://aws.amazon.com/) for hosting and database services. Data is encrypted in transit and at rest.
- Your name and email is shared with [Loops](https://loops.so/), an email marketing service, in order to send you updates on Planto. You can opt out of these emails at any time with one click.
- Your name and email are shared with our payment processor [Stripe](https://stripe.com/) if you subscribe to a paid plan or purchase the $10 trial.
- Basic usage data is sent to [Google Analytics](https://analytics.google.com/) to help track usage and make improvements.
- [Relace](https://relace.ai/) for an instant apply AI model that speeds up and reduces the cost of file edits. Used as a fallback if Planto is unable to apply edits deterministically. Inputs are the original file and the edit snippet from a Planto response.
- [Rollbar](https://rollbar.com/) for error tracking and alerting. It's unlikely that any user data would be shared with Rollbar. If it was, it would be minimal and incidental to error reporting.

Apart from the above list, no other data will be shared with any other third party. The list will be updated if any new third party services are introduced.

Data sent to a model provider like OpenAI or OpenRouter.ai is subject to the model provider's privacy and data retention policies.

See our full [Privacy Policy](https://planto.ai/privacy) for more details.
