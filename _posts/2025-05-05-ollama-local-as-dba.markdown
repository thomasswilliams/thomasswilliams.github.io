---
layout: post
title:  "How I use LLMs (AKA \"AI\") in 2025 as a DBA"
date:   2025-05-05 12:00:00 +1000
categories: ['development', 'general']
---

Over the last couple of months I've used LLMs to help me write, especially to help me write code (at the moment CodeGPT is making suggestions in VS Code, as I type).

There are of course lots of ways to use LLMs. I'm most comfortable running them locally for work purposes, and accepting the limitations. Ollama <https://ollama.com/> seems the easiest way to do this with a variety of models. Plus, I'm pleasantly surprised that Ollama models run on older laptops with onboard graphics and "only" 16GB memory. Keep in mind that I'm a little late to LLMs, and as at early 2025 have not yet paid any money for LLMs.

For Windows, I'd strongly suggest running Ollama in WSL (Windows Subsystem for Linux). It’s a bit more work up front, but once done has more flexibility,  especially in corporate environments that may be somewhat locked down.

In this post I'll be using a basic 3B model which is around 3.5GB in size. When running locally, you will probably notice slowness on the first load of a model. I'll only skim over the steps; there are plenty of resources online for setting this up.

## Prep steps For Windows

* install Windows Terminal
* install WSL
* install a Linux OS (for example, Ubuntu) in WSL
* you may need to edit “.wslconfig” (in your Windows user folder e.g. _C:&#92;Users&#92;&lt;your username>_) to give enough CPU and memory - without taking it all - for example here's what I've used on a 16GB RAM/8 CPU laptop:

```ini
[wsl2]
memory=12GB
processors=6
```

Make sure you restart any running WSL instances to pick up changes to ".wslconfig".

## Install and use Ollama

The rest of the steps work on Linux (in WSL or not) and Mac with a little tweaking:

* make sure your OS is up-to-date: `sudo apt update && sudo apt upgrade`
* install curl, if you don't already have it: `sudo apt install curl`
* download & install Ollama: `curl -fsSL https://ollama.com/install.sh | sh`
* depending on your machine specs, I'd recommend the following environment variables which run one model at a time:

```bash
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_MAX_LOADED_MODELS=1
```

* download a model for ollama: `ollama pull llama3.2:3b`

There are multiple ways to get output from a model:

1. can run from the command line and ask a question (remember, will take some time to first load, depending on the size of the model): `ollama run llama3.2:3b "How can you help?"`
  * as  bonus, you can also have the model look at files: `ollama run llama3.2:3b "Summarize the content of this file in 100 words or less." < .bashrc`

2. run a chat model interactively on the command line: `ollama run llama3.2:3b`
  * type “/bye” to exit

3. call a HTTP API, may take a couple of seconds while processing (note I needed to do some fiddling with the proxy in a corporate environment to achieve this, your mileage may vary):

```bash
curl --location 'http://localhost:11434/api/generate' \
--data '{
  "model": "llama3.2:3b",
  "prompt": "How can you help?",
  "stream": false
}'
```

Look for the "response" in returned JSON.

Using method #1, #2 or #3, the model runs in the background for a few minutes once started - can see with: `ollama ps` _(also shows how Ollama is using resources)_

The API option is interesting as it allows you to call a model from other programs.

A handy command to update all Ollama models: `ollama list | tail -n +2 | awk '{print $1}' | xargs -I {} ollama pull {}` _(thanks to https://til.tafkas.net/posts/upgrade-all-installed-ollama-models-using-command-line/)_

Lastly, some interesting things to keep an eye on now that you have Ollama installed and running:

* shellm <https://github.com/Biont/shellm>: LLM from the command line, interact with other commands like `ls`
* zev <https://github.com/dtnewman/zev>: ask an LLM to write code from the command line
* CodeGPT in VS Code <https://blog.codegpt.co/create-your-own-and-custom-copilot-in-vscode-with-ollama-and-codegpt-736277a60298>: the `codellama` model is a lot better at writing code
* Qwen models <https://simonwillison.net/2025/Apr/29/qwen-3/>: explains the thinking process, fascinating
* Llama vision <https://medium.com/@tapanbabbar/how-to-run-llama-3-2-vision-on-ollama-a-game-changer-for-edge-ai-80cb0e8d8928>: wow, I had this extract data from scanned documents