package github

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

const (
	ref = "dev-rel"
	githubAPI = "https://api.github.com"
)

type GitHubClient struct {
	c     *http.Client
	repo  string
	token string
}

func (gh *GitHubClient) SetStatus(sha string, status GitHubStatus) error {
	//var ret GitHubStatus
	url := fmt.Sprintf("%s/repos/%s/statuses/%s", githubAPI, gh.repo, sha)

	b, _ := json.Marshal(status)
	payload := bytes.NewReader(b)
	req, err := http.NewRequest(http.MethodPost, url, payload)

	//sc, err := gh.makeRequest(req, &ret)
	sc, err := gh.makeRequest2(req)
	if err != nil {
		return err
	}
	if sc != 201 {
		return fmt.Errorf("status code is %d", sc)
	}
	return nil
}

func (gh *GitHubClient) RunWorkflow(name string, input map[string]string) error {
	url := fmt.Sprintf("%s/repos/%s/actions/workflows/%s/dispatches", githubAPI, gh.repo, name)
	wf := GitHubWorkflow{
		Ref:   ref,
		Input: input,
	}
	b, _ := json.Marshal(wf)
	payload := bytes.NewReader(b)
	req, err := http.NewRequest(http.MethodPost, url, payload)
	req.Header.Add("Accept", "application/vnd.github.everest-preview+json")

	sc, err := gh.makeRequest2(req)
	if err != nil {
		return err
	}
	if sc != 204 {
		return fmt.Errorf("status code is %d", sc)
	}
	return nil

}

func (gh *GitHubClient) makeRequest(req *http.Request, ret interface{}) (int, error) {
	// Add auth token
	authHeader := fmt.Sprintf("token %s", gh.token)
	req.Header.Add("Authorization", authHeader)
	// Make req
	resp, err := gh.c.Do(req)
	if err != nil {
		return -1, err
	}
	defer resp.Body.Close()
	// return status code and JSON obj
	return resp.StatusCode, json.NewDecoder(resp.Body).Decode(ret)
}

func (gh *GitHubClient) makeRequest2(req *http.Request) (int, error) {
	// Add auth token
	authHeader := fmt.Sprintf("token %s", gh.token)
	req.Header.Add("Authorization", authHeader)
	// Make req
	resp, err := gh.c.Do(req)
	if err != nil {
		return -1, err
	}
	resp.Body.Close()
	// Return sc
	return resp.StatusCode, nil
}

func New(repo, token string) *GitHubClient {
	gh := new(GitHubClient)
	gh.c = httpClient
	gh.repo = repo
	gh.token = token

	return gh
}
