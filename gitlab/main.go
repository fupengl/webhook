package gitlab

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os/exec"
	"encoding/json"
)

var config Config

func SetConfig(conf Config) {
	config = conf
}

func HookHandler(w http.ResponseWriter, r *http.Request) {
	var hook Webhook

	// read request body
	var data, err = ioutil.ReadAll(r.Body)
	if err != nil {
		log.Fatal("Failed to read request: %s", err)
		return
	}

	// unmarshal request body
	err = json.Unmarshal(data, &hook)
	if err != nil {
		log.Fatal("Failed to parse request: %s", err)
		return
	}

	// find matching config for repository name
	for _, repo := range config.Repositories {
		if repo.Name != hook.Project.PathWithNamespace {
			continue
		}

		deployUri := hook.Project.Name
		if (len(repo.Alias) != 0) {
			deployUri = repo.Alias
		}

		//execute commands for repository
		for _, cmd := range repo.Commands {
			var command = exec.Command(cmd, hook.Project.PathWithNamespace, deployUri, hook.Repository.URL, hook.EventName, hook.Ref)
			out, err := command.Output()
			if err != nil {
				log.Fatal("Failed to execute command: %s", err)
				continue
			}
			log.Println("Executed: " + cmd)
			log.Println("Output: " + string(out))
			fmt.Println(string(out))
		}
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("success"))
}
