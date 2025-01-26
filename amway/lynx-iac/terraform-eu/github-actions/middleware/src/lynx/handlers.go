package main

import (
	"middleware/github"
	"fmt"
	"os"
	"strconv"
	"strings"
	"sync"
)

const (
	pendingState             = "pending"
	openedStatusDescription  = "disabled"
	syncStatusDescription    = "disabled"
    svcSyncStatusDescription = "disabled"
)

var (
	githubToken = os.Getenv("GIT_TOKEN")
)

func setGitHubStatuses(statusDescription string, pullEvent *github.PullRequestEvent) error {
	// Get couple useful vars
	repoName := pullEvent.PullRequest.Base.Repo.FullName
	sha := pullEvent.PullRequest.Head.Sha
	// Create git obj
	gh := github.New(repoName, githubToken)
	// Get list of mandatory checks based on repo
	contexts, ok := ctxMap[repoName]
	if !ok {
		return fmt.Errorf("Unknown repository")
	}
	// Make api calls to set def statuses
	var wg sync.WaitGroup
	for _, ctx := range contexts {
		wg.Add(1)
		go func(sha, ctx string, wg *sync.WaitGroup) {
			defer wg.Done()
			status := github.GitHubStatus{
				Context:     ctx,
				State:       pendingState,
				Description: statusDescription,
			}
			err := gh.SetStatus(sha, status)
			if err != nil {
				// no proper error handling just log it
				log.Errorf("%s %s\n", reqID, err)
			}
		}(sha, ctx, &wg)
	}
	wg.Wait()
	return nil
}

func spawnGitHubWorkflow(pullEvent *github.PullRequestEvent) error {
	label := pullEvent.Label.Name
	repoName := pullEvent.PullRequest.Base.Repo.FullName
	gh := github.New(repoName, githubToken)

	workflowName, ok := userLabelMap[label]
	if !ok {
		log.Warningf("%s label %s isn't supported", reqID, label)
		return nil
	}

	input := make(map[string]string)
	input["ref"] = pullEvent.PullRequest.Head.Ref
	input["sha"] = pullEvent.PullRequest.Head.Sha
	input["num"] = strconv.Itoa(pullEvent.PullRequest.Number)
	input["user"] = strings.ToLower(pullEvent.Sender.Login)
	input["base_ref"] = pullEvent.PullRequest.Base.Ref

	if err := gh.RunWorkflow(workflowName, input); err != nil {
		return fmt.Errorf("failed to run github wf %s, %s", workflowName, err)
	}
	return nil
}

func handleOpenedEvent(pullEvent *github.PullRequestEvent) error {
	// Just set required mandatiry statuses
	return setGitHubStatuses(openedStatusDescription, pullEvent)
}

func handleLabeledEvent(pullEvent *github.PullRequestEvent) error {
	// Run proper test
	label := pullEvent.Label.Name
	user := strings.ToLower(pullEvent.Sender.Login)

	// if some human user set 'merge it' or restarted  label (this is forbidden)
	if serviceLabelMap[label] && !serviceUsers[user] {
		return fmt.Errorf("For user %s setting '%s' label not allowed", user, label)
	}

	return spawnGitHubWorkflow(pullEvent)
}

func handleSynchronizedEvent(pullEvent *github.PullRequestEvent) error {
	// run all tests if branch was updated by Bender/Leela
	user := strings.ToLower(pullEvent.Sender.Login)

	if serviceUsers[user] {
		log.Infof("%s Service user synchronized pull request\n", reqID)
		// Set statuses that pull request was updated
		if err := setGitHubStatuses(svcSyncStatusDescription, pullEvent); err != nil {
			return err
		}
		// Sync action made by Bender is the same as
		// set restarted label (all jobs will be spawned)
		pullEvent.Label.Name = restart
		return spawnGitHubWorkflow(pullEvent)
	}
	// Regular commit to branch, just set mandatory statuses
	return setGitHubStatuses(syncStatusDescription, pullEvent)
}
