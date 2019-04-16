package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"webhook/gitlab"
)

var config gitlab.Config
var configFile string

func main() {
	args := os.Args

	//if we have a "real" argument we take this as conf path to the config file
	if len(args) > 1 {
		configFile = args[1]
	} else {
		configFile = "config.json"
	}

	// load config
	config, err := loadConfig(configFile)
	if err != nil {
		log.Fatalf("Failed to read config: %s", err)
	}

	// open log file
	writer, err := os.OpenFile(config.Logfile, os.O_RDWR|os.O_APPEND|os.O_CREATE, 0666)
	if err != nil {
		log.Fatalf("Failed to open log file: %s", err)
		os.Exit(1)
	}

	gitlab.SetConfig(config)

	// setting logging output
	log.SetOutput(writer)

	// mounted gitlab handle
	http.HandleFunc("/", gitlab.HookHandler)

	address := fmt.Sprintf("%s:%d", config.Address, config.Port)
	log.Println(fmt.Sprintf("Listening on %s", address))

	srv := &http.Server{
		Addr: address,
	}

	// starting server
	go func() {
		err := srv.ListenAndServe()
		if err != nil {
			log.Fatal(fmt.Sprintf("start server error: %s", err.Error()))
		}
	}()

	quit := make(chan os.Signal)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGHUP, syscall.SIGQUIT, syscall.SIGKILL, syscall.SIGTERM)
	<-quit
	log.Print("close server ...")

	defer writer.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err = srv.Shutdown(ctx)
	if err != nil {
		log.Fatal("close server error: %s", err.Error())
		return
	}

	log.Print("close server successfully")
}

func loadConfig(configFile string) (gitlab.Config, error) {
	file, err := ioutil.ReadFile(configFile)
	if err != nil {
		return gitlab.Config{}, err
	}

	err = json.Unmarshal(file, &config)
	if err != nil {
		return gitlab.Config{}, err
	}

	return config, nil
}
