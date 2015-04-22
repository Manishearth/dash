---
layout: page
title: "Running tests"
category: dev
date: 2015-04-22 21:44:35
---


To run tests, make sure everything is built:

```

go get github.com/Manishearth/cs733/assignment3/raft

cd dash
go build
cd ../server
go build
cd ..
```

Then, run `bash test_script.sh`

This script will run a bunch of tests on Dash