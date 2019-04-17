package gitlab

import (
	"io/ioutil"
	"log"
	"net/http"
	"os/exec"
	"encoding/json"
	"time"
	"os"
	"fmt"
	"strings"
)

var config Config
var jobChan chan JobItem

type JobItem struct {
	Repo ConfigRepository
	Hook Webhook
}

func SetConfig(conf Config) {
	config = conf
}

func SetJob(job chan JobItem) {
	jobChan = job
	go worker(jobChan)
}

func worker(jobChan <-chan JobItem) {
	for {
		select {
		case job := <-jobChan:
			// execute commands for repository
			log.Printf("执行任务 %s \n", job.Hook.Project.Name)

			deployPath := job.Hook.Project.Name
			if (len(job.Repo.Alias) != 0) {
				deployPath = job.Repo.Alias
			}

			// TODO add timeout
			for _, cmd := range job.Repo.Commands {
				var command = exec.Command(cmd)
				command.Env = append(
					os.Environ(),
					fmt.Sprintf("WEBHOOK_PROJECT_NAME=%s", job.Hook.Project.PathWithNamespace),
					fmt.Sprintf("WEBHOOK_DEPLOY_PATH=%s", deployPath),
					fmt.Sprintf("WEBHOOK_REPOSITORY_URL=%s", job.Hook.Repository.URL),
					fmt.Sprintf("WEBHOOK_REPOSITORY_EVENT=%s", job.Hook.EventName),
					fmt.Sprintf("WEBHOOK_REPOSITORY_BRANCH=%s", strings.Replace(job.Hook.Ref,"refs/heads/","", 1)),
				)
				out, err := command.Output()
				if err != nil {
					log.Fatal("Failed to execute command: %s", err)
					continue
				}
				log.Println("Executed: " + cmd)
				log.Println("Output: " + string(out))
			}
		default:
			time.Sleep(1 * time.Second)
		}
	}
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

		jobChan <- JobItem{
			Repo: repo,
			Hook: hook,
		}
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("success"))
}
