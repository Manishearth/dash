---
layout: page
title: "Setup - Client"
category: tut
date: 2015-04-18 23:01:46
---


To setup `dash` on the client, copy the host/port keys from the server config files (see [server setup](2015-04-18-setup.md)) and list them in `config.json` in your installation folder.


A typical `config.json` will look like:


```
{
 "Hosts": ["10.2.100.30", "10.2.100.31", "10.2.100.32", "10.2.100.33", "10.2.100.34"],
 "Ports": [8080, 8080, 8080, 8080, 8080]
}
```

Make sure there are no trailing commas

To install,

```
go get github.com/Manishearth/cs733/assignment3/raft
go get github.com/Manishearth/dash/dash
go build github.com/Manishearth/dash/dash
```



To run, simply run `dash "command"`, e.g. `dash apt-get update` or `dash "echo 'foo bar'>/etc/something/settings.conf"` from the installation folder.
`dash` will exit when it has reported the command to the cluster. Note that this does not necessarily mean that the command will run -- it is possible that
the server which received the command will be shut down before it can replicate it.