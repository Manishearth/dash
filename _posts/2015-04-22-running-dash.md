---
layout: page
title: "Running Dash"
category: tut
date: 2015-04-22 21:46:36
---


To run Dash, first make sure that Dash is set up (see [server setup](2015-04-18-setup.md) and [client setup](2015-04-18-setup-client)).


You can either run Dash directly or use the Dash shell. To run Dash directly, simply run `./dash config.json foo bar baz`, where `foo bar baz` is the command you wish to run

To run Dash in shell mode, run `./dash -s config.json`. This will bring up a `dash>` prompt to which you can feed your commands.

Dash will exit (or in the case of the Dash shell, it will move to the next prompt) when the command has been sent to a leader (client append). Bear in mind that there
will be some time between a successful client append and the execution of the command; and a successful client append need not mean that the command will be executed at all.

If you wish to write dependent commands, do not run them one after the other -- due to the nature of the replication you should run them all as a single command, or use a replicated shell script.

