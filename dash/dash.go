package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"github.com/Manishearth/cs733/assignment3/raft"
	"io/ioutil"
	"log"
	"net/rpc"
	"os"
	"strings"
)

func main() {
	raft.Register()
	if len(os.Args) < 3 {
		log.Fatal("Not enough arguments, please pass the path of the config file")
	}
	path := os.Args[1]
	shell := false
	if path == "-s" {
		path = os.Args[2]
		shell = true
	}

	file, e := ioutil.ReadFile(path)
	if e != nil {
		log.Fatal("")
	}
	var set settings
	json.Unmarshal(file, &set)
	i := uint(0)

Outer:
	for true {
		var cmd string
		var err error
		if shell {
			fmt.Printf("dash> ")
			in := bufio.NewReader(os.Stdin)
			cmd, err = in.ReadString('\n')
			if err != nil {
				fmt.Println("Error reading from terminal: ", err)
				return
			}
		} else {
			cmd = strings.Join(os.Args[2:], " ")
		}
		fmt.Println("\tIssuing command: ", cmd)
	Inner:
		for true {
			client, err := rpc.DialHTTP("tcp", fmt.Sprintf("%v:%v", set.Hosts[i], set.Ports[i]))
			if err != nil {
				// Server unavailable
				// Move ahead
				i++
				if i >= uint(len(set.Hosts)) {
					i = 0
				}
				continue Inner
			}
			var reply raft.ClientAppendResponse
			err = client.Call("ClientAppendHandler.ClientAppend", &cmd, &reply)
			if reply.Queued {
				if !shell {
					return
				}
				continue Outer
			} else {
				// Let's try going to the leader indicated, if it is different
				if i != reply.LeaderId {
					i = reply.LeaderId
				}
			}
		}
		if !shell {
			return
		}
	}

}

type settings struct {
	Hosts []string
	Ports []uint
}
