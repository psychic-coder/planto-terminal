---
sidebar_position: 3
sidebar_label: Settings
---

# Model Settings

Planto gives you a number of ways to control the models and models settings used in your plans. Changes to models and model settings are [version controlled](../core-concepts/version-control.md) and can be [branched](../core-concepts/branches.md).

## `models` and `set-model`

You can see the current plan's models and model settings with the `models` command and change them with the `set-model` command.

```bash
planto models # show the current AI models and model settings
planto models available # show all available models
planto set-model # select from a list of models, model packs, and settings
planto set-model planner openrouter/anthropic/claude-3.7-sonnet # set the main planner model to Claude Sonnet 3.7 from OpenRouter.ai
planto set-model builder temperature 0.1 # set the builder model's temperature to 0.1
planto set-model max-tokens 4000 # set the planner model overall token limit to 4000
planto set-model max-convo-tokens 20000  # set how large the conversation can grow before Planto starts using summaries
```

## Model Defaults 

`set-model` updates model settings for the current plan. If you want to change the default model settings for all new plans, use `set-model default`.

```bash
planto models default # show the default model settings
planto set-model default # select from a list of models and settings
planto set-model default planner openai/gpt-4o # set the default planner model to OpenAI gpt-4o
```

## Model Packs

Instead of changing models for each role one by one, model packs let you switch out all roles at once. It's the recommended way to manage models.

You can list available model packs with `model-packs`:

```bash
planto model-packs # list all available model packs
```

You can create your own model packs with `model-packs create`, list built-in and custom model packs with `model-packs`, show a specific model pack with `model-packs show`, update a model pack with `model-packs update`, and remove custom model packs with `model-packs delete`.

```bash
planto set-model # select from a list of model packs for the current plan
planto set-model default # select from a list of model packs to set as the default for all new plans
planto set-model anthropic-claude-3.5-sonnet-gpt-4o # set the current plan's model pack by name
planto set-model default Mixtral-8x22b/Mixtral-8x7b/gpt-4o # set the default model pack for all new plans

planto model-packs # list built-in and custom model packs
planto model-packs create # create a new custom model pack
planto model-packs --custom # list only custom model packs
planto model-packs show # show a specific model pack
planto model-packs update # update a model pack
planto model-packs delete # delete a custom model pack
```

## Custom Models

Use `models add` to add a custom model and use any provider that is compatible with OpenAI, including OpenRouter.ai, Together.ai, Ollama, Replicate, and more.

```bash
planto models add # add a custom model
planto models available --custom # show all available custom models
planto models delete # delete a custom model
```
