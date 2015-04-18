#!/bin/bash

# Shell script based test for Dash
#
# Written in bash instead of Go because the internal Raft
# implementation is already tested in the `raft` package
# so we only need to ensure that the commandline interface is working
# as expected
#
# We use `sleep 10` all over the place in case an extra election
# happened between the two commands (which can take a while)

# Exit on failure of a command


# Array of PIDs
declare -a PID

# Kill all children on termination
trap "bye" SIGTERM SIGKILL INT EXIT

# Clear test logs and temporary files
rm *.log 2>/dev/null
rm server/server*/*tmp 2>/dev/null
rm server/server*/raft_persistence.json 2>/dev/null

set -e

echo 'Make sure you have run `go build` in server/ and dash/ before running'

if [[ 0 -ne $(pgrep server | wc -l) ]]; then
    echo "NOTE: Found some existing processes called 'server'"
    echo '      Please run `killall server` to get rid of these'
    echo '      if they are leftover from a previous run'
fi

cd server


# Spawn a server 
spawn() {
    cd "server$1"
    ../server config.json >>../../$1.log 2>&1 &
    PID[$1]="$!"
    echo -e "\tServer $1 spawned with PID ${PID[$1]}"
    cd ..
}

# Shut down all forked processes
bye() {
    kill -9 ${PID[0]} ${PID[1]} ${PID[2]} ${PID[3]} ${PID[4]}
}

# Check if a `touch` command got replicated
# First parameter is number of servers it should have been replicated on
# Second parameter is name of file
# Third parameter is id of server which it is guaranteed to have replicated on
checkrepl(){
    # Wait until file gets replicated
    while [[ $1 -ne $(ls server*/$2 2>/dev/null | wc -l) ]]; do
        sleep 1
    done
    echo -e "\tFiles found"
    if [[ 0 -ne $1 ]]; then
        # In case we aren't checking for removal
        # check if there is only one file in the given directory
        if [[ 1 -ne $(ls server$3/$2 2>/dev/null | wc -l) ]]; then
            echo "$2 did not get replicated"
            exit 2
        fi
    fi
}
echo "Spawning servers"
spawn 0
spawn 1
spawn 2
spawn 3
spawn 4
echo "Servers spawned"

sleep 4

echo "Testing basic replication"
../dash/dash ../dash/config.json touch foo.tmp
echo -e "\tCommand sent to leader"
#sleep 10
checkrepl 5 foo.tmp 0 # Should be replicated everywhere
echo "File successfully replicated"

echo "Testing replication after single server deleted"
kill -9 ${PID[0]}
echo -e "\tServer 0 deleted"
sleep 10
../dash/dash ../dash/config.json touch bar.tmp
echo -e "\tCommand sent to leader"
#sleep 10
checkrepl 4 bar.tmp 1 # Should be replicated on server1-server4
echo "Replication works after deletion of single server"

echo "Testing execution of old commands after server restarted"
spawn 0
sleep 10
checkrepl 5 bar.tmp 0 # Should become replicated on all servers incl server0
echo "Command executed fine"

echo "Testing replication after two servers deleted"
kill -9 ${PID[0]} ${PID[1]}
echo -e "\tServers 0,1 deleted"
sleep 10
../dash/dash ../dash/config.json touch baz.tmp
echo -e "\tCommand sent to leader"
#sleep 10
checkrepl 3 baz.tmp 2 # Should be replicated on server2-server4
echo "Replication works after deletion of two servers"

echo "Testing execution of old commands after server restarted"
spawn 0
sleep 10
checkrepl 4 baz.tmp 0 # Should become replicated on all servers except server1
echo "Command executed fine"

echo "Testing execution of old commands after second server restarted"
spawn 1
sleep 10
checkrepl 5 baz.tmp 1 # Should become replicated on all servers incl server1
echo "Command executed fine"

echo "Testing execution of new command after a lot of servers have been restarted"
../dash/dash ../dash/config.json touch qux.tmp
echo -e "\tCommand sent to leader"
#sleep 10
checkrepl 5 qux.tmp 0
echo "New command executed fine"

rm server*/*tmp

echo "PASSED"