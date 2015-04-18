---
layout: default
title: "The Distributed Shell"
---

Quite often one has to manage a set of computers which are used by many others. A typical example is a computer lab.

In such a case, not all computers may be up at a given time. This can be a headache for system administrators -- they
must turn all of the computers on to run updates and cleanup, or they must update the machines incrementally.

It is quite possible to run a script that continually tries to run a given command on all the machines until it succeeds.
However, this requires a "leader" machine that is guaranteed to be on for a long period of time. Such a machine is not always
available.

Dash solves this problem by using [Raft](http://ramcloud.stanford.edu/raft.pdf) to replicate commands across machines. Simply calling
`dash apt-get update`<sup>1</sup> from a machine on the same network will instruct the machines to replicate the command across the cluster,
and run it when it has been replicated to a majority. If a machine is booted up later, it will be told by the other machines to run the command too.



<small>1. Currently Dash doesn't have any security model so for this to work it will need to be run as root and will be vulnerable. ECDSA-based security is planned.</small>