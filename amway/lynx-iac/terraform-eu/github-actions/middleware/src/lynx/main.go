package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"

	"middleware/github"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"

	"github.com/pymhd/go-logging"
	"github.com/pymhd/go-logging/handlers"
)

const (
	GitHubSecretHeader = "X-Hub-Signature"
)

var (
	reqID   string
	enabled = os.Getenv("ENABLED")
	secret  = os.Getenv("GIT_SECRET")
	allowed = map[string]bool{"opened": true, "reopened": true, "labeled": true, "synchronize": true}
	log     = logger.New("main", handlers.StreamHandler{}, logger.DEBUG, logger.OTIME|logger.OLEVEL)
)

func PostRequestHandler(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	reqID = req.RequestContext.RequestID
	// First check if func is enabled
	switch enabled {
	case "1", "y", "yes", "true":
		log.Debugf("%s Lambda function is enabled. Continue\n", reqID)
	default:
		log.Debugf("%s Lambda function is turned off. Exit\n", reqID)
		return genResponse(http.StatusOK, http.StatusText(http.StatusOK))
	}
	// if not signed
	if ok := reqIsSigned(req); !ok {
		log.Errorf("%s Auth error, exit\n", reqID)
		return genResponse(http.StatusForbidden, http.StatusText(http.StatusForbidden))
	}
	// if not proper body
	pullEvent := new(github.PullRequestEvent)
	if err := getReqPayload(req, pullEvent); err != nil {
		log.Errorf("%s Could not get proper JSON body\n", reqID)
		return genResponse(http.StatusBadRequest, err.Error())
	}
	// err is nil by this moment
	var err error
	action := pullEvent.Action
	switch action {
	case "opened", "reopened":
		log.Infof("%s Opened pull request, mandatory statuses wil be set\n", reqID)
		err = handleOpenedEvent(pullEvent)
	case "labeled":
		log.Infof("%s Labeled pull request, some wf will be triggered\n", reqID)
		err = handleLabeledEvent(pullEvent)
	case "synchronize":
		log.Infof("%s Sync pull request. Based on sender login statuses will be set or merge job spawned\n", reqID)
		err = handleSynchronizedEvent(pullEvent)
	default:
		log.Infof("%s Ignoring '%s' event\n", reqID, pullEvent.Action)
		return genResponse(http.StatusOK, http.StatusText(http.StatusOK))
	}
	if err != nil {
		log.Errorf("%s Could not handle '%s' event : %s\n", reqID, pullEvent.Action, err)
		// Send error meassage to skype
		num := pullEvent.Number
		repo := pullEvent.PullRequest.Head.Repo.ShortName
		notificationMsg := fmt.Sprintf("(shock) v2 Middleware Error: "+
			"Failed to handle '%s' event for %s pull num %d. Error: %s. RequestID: %s",
			action, repo, num, err, reqID)
		log.Errorf(notificationMsg)
	}
	// Return success to GitHub
	return genResponse(http.StatusOK, http.StatusText(http.StatusOK))
}

func reqIsSigned(req events.APIGatewayProxyRequest) bool {
	headerSig, ok := req.Headers[GitHubSecretHeader]
	if !ok {
		// No X-Hub-Signature header in req
		return false
	}

	signature := getSignature(req.Body, secret)
	if signature != headerSig {
		// Wrong value for X-Hub-Signature
		return false
	}
	return true

}

func getReqPayload(req events.APIGatewayProxyRequest, pullEvent *github.PullRequestEvent) error {
	r := strings.NewReader(req.Body)
	return json.NewDecoder(r).Decode(pullEvent)
}

func genResponse(code int, body string) (events.APIGatewayProxyResponse, error) {
	headers := map[string]string{"Content-Type": "text/html"}
	response := events.APIGatewayProxyResponse{StatusCode: code, Body: body, Headers: headers}
	return response, nil
}

func main() {
	lambda.Start(PostRequestHandler)
}
