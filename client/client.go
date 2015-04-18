package main

import (
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
	file, e := ioutil.ReadFile(path)
	if e != nil {
		log.Fatal("")
	}
	var set settings
	json.Unmarshal(file, &set)
	i := uint(0)
	for true {
		client, err := rpc.DialHTTP("tcp", fmt.Sprintf("%v:%v", set.Hosts[i], set.Ports[i]))
		if err != nil {
			// Server unavailable
			// Move ahead
			i++
			if i >= uint(len(set.Hosts)) {
				i = 0
			}
		}
		var reply raft.ClientAppendResponse
		cmd := strings.Join(os.Args[2:], " ")
		fmt.Println(cmd)
		err = client.Call("ClientAppendHandler.ClientAppend", &cmd, &reply)
		if reply.Queued {
			return
		} else {
			i = reply.LeaderId
		}
	}
}

type settings struct {
	Hosts []string
	Ports []uint
}
