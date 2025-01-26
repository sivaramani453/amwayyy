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

var contextsForRU = []string{"Build + JSP tests", "Sonar Ent test", "Spring context test", "UI Unit tests", "Unit + Web tests", "Update test (RU)", "Update test (KZ UA)", "Integration tests part 1", "Integration tests part 2", "Shaper test"}

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
	// ru
	case "AmwayACS/lynx-ru":
		contexts = contextsForRU
	// any other (for the future)
	default:
		contexts = contextsForRU
	}

	for _, ctx := range contexts {
		wg.Add(1)
		go updateGithubStatus(project, ctx, sha, &wg)
	}
	wg.Wait()
	return nil
}
