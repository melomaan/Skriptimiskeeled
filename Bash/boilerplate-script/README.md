# Overview

This directory contains the Bash script that I've settled upon to get started with any Bash project. It is heavily influenced by Maciej Radzikowski's [minimal safe Bash script template](https://betterdev.blog/minimal-safe-bash-script-template/), which is why I will not be explaining what is already explained by him.

What I did find lacking on his side was the mention of [shell parameter expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html), which is a really powerful way to do all sorts of operations on a given string and really should be required reading to anyone who is writing any kind of slightly more advanced (or even elegant) Bash.

Another nice bit of reading is the [Command Line Interface Guidelines](https://clig.dev), which goes over more generic concepts in designing tools based on a command line interface.

Andy Dote's [post relating to Bash scripting](https://andydote.co.uk/2020/08/28/better-bashing-through-technology/) also has a very good set of paradigms to incorporate into Bash scripts, though I wholly dislike the way he prints the script's usage; that many `echo` statements in a row is borderline criminal when [here documents](https://en.wikipedia.org/wiki/Here_document#Unix_shells) exist. For better visibility I'll link to the [Consul](https://github.com/hashicorp/terraform-aws-consul/search?l=shell) and [Terraform](https://github.com/hashicorp/terraform-aws-vault/search?l=shell) shell code directly.

## Usage

Just save the script in its raw form, replace values, add or remove how you deem fit for your use case. The `setup_colors`, `msg`, and `die` functions could be moved to a separate file, which is then sourced at the very start of the script, but I decided not to do that here to make it easier to just copy-paste and get going.
