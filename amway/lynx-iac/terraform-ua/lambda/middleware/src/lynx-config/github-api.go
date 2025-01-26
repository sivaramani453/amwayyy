package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"sync"
)

const (
	Description = "disabled"
	State       = "pending"
	URL         = "https://amway-prod.tt.com.pl"
	GithubURL   = "https://api.github.com/repos/"
)

// Because now we have diff mandatory checks for region
var (
	contextsForEU = []string{}
	contextsForRU = []string{}
	contextsForIN = []string{}
)

type GithubStatusPayload struct {
	Context     string `json:"context"`
	State       string `json:"state"`
	Description string `json:"description"`
	TargetURL   string `json:"target_url"`
}

func updateGithubStatus(project, ctx, sha string, wg *sync.WaitGroup) {
	defer wg.Done()
	payload := GithubStatusPayload{Context: ctx, State: State, Description: Description, TargetURL: URL}
	payloadBytes, _ := json.Marshal(payload)
	client := &http.Client{}
	req, err := http.NewRequest("POST", GithubURL+project+"/statuses/"+sha, bytes.NewReader(payloadBytes))
	token := fmt.Sprintf("token %s", os.Getenv("TOKEN"))
	req.Header.Add("Authorization", token)
	resp, err := client.Do(req)
	if err != nil {
		log.Errorf("%s %s \n", getReqID(), err)
		return
	}
	resp.Body.Close()
	log.Infof("%s Status code received from github: %d (conext: %s, project: %s) \n", getReqID(), resp.StatusCode, ctx, project)
}

func createGithubStatuses(project, sha string) error {
	var wg sync.WaitGroup
	var contexts []string

	switch project {
	// eu
	case "AmwayACS/lynx-config":
		contexts = contextsForEU
	// ru
	case "AmwayACS/lynx-ru-config":
		contexts = contextsForRU
	// india
	case "AmwayACS/lynx-in-config":
		contexts = contextsForIN
	// any other (for the future)
	default:
		contexts = contextsForEU
	}

	for _, ctx := range contexts {
		wg.Add(1)
		go updateGithubStatus(project, ctx, sha, &wg)
	}
	wg.Wait()
	return nil
}
