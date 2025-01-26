package main

import (
	"crypto/hmac"
	"crypto/sha1"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"

	"github.com/pymhd/go-logging"
	"github.com/pymhd/go-logging/handlers"
)

const (
	gitSecretHeader   = "X-Hub-Signature"
	BambooPlanPostfix = "-RTSHO"
	NULL              = "null"
)

var (
	reqID          string
	bambooLabel    string
	labelMap       map[string]bool
	allowedActions = map[string]bool{"opened": true, "labeled": true, "reopened": true, "synchronize": true}
	projectMap     = map[string]string{"AmwayACS/lynx-config": "AM", "AmwayACS/lynx-ru-config": "AER"}
	postfixMap     = map[string]string{"shaper": "RTSHO"}
	log            = logger.New("main", handlers.StreamHandler{}, logger.DEBUG, logger.OTIME|logger.OLEVEL)
)

func PostHandler(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	//rewrite some global vars, because it's value could store data from previous
	// lambda calls during the same exec context
	reqID = req.RequestContext.RequestID
	bambooLabel = NULL
	labelMap = make(map[string]bool, 0)

	log.Infof("%s Lamda middleware-webhook triggered\n", getReqID())
	secret, ok := req.Headers[gitSecretHeader]
	if !ok {
		//this request is not from github
		log.Errorf("%s Got request without github secret header, exit\n", getReqID())
		// http.StatusForbidden = 403, http.StatusText(http.StatusForbidden) - Forbidden
		// return 403 status code with text Forbidden (see net/http constants in godoc)
		return genResponse(http.StatusForbidden, http.StatusText(http.StatusForbidden))
	}
	signature := getSignature(req.Body, os.Getenv("SECRET"))
	if secret != signature {
		log.Errorf("%s Secert in header does not match secret specifired in aws lambda func\n", getReqID())
		log.Warningf("%s %s != %s\n", getReqID(), secret, signature)
		// return the same as if there was no secret, see above comments
		return genResponse(http.StatusForbidden, http.StatusText(http.StatusForbidden))
	}
	// create new pointer to PullRequestPayload obj See types.go file for the structure
	payload := new(PullRequestPayload)
	if err := json.NewDecoder(strings.NewReader(req.Body)).Decode(payload); err != nil {
		log.Errorf("%s Could not parse json payload (%s)\n", getReqID(), err)
		// This means we did not get valid json payload in POST request to aws API gateway
		// so we will return 501 status code with "internal server error" message
		return genResponse(http.StatusInternalServerError, http.StatusText(http.StatusInternalServerError))
	}

	log.Debugf("%s Invoked by action: %s, pull request number: %d, pull request ref: %s, sha: %s by login: %s, label: %s \n", getReqID(), payload.Action, payload.PullRequest.Number, payload.PullRequest.Head.Ref, payload.PullRequest.Head.Sha, payload.Sender.Login, payload.Label.Name)
	// if action in allowedActions, else we will skip all request processing
	// for instance for action = closed
	if allowedActions[payload.Action] {
		// if action is labeled we need to distinct the label itself
		if payload.Action == "labeled" {
			switch payload.Label.Name {
			case "run shaper test":
				log.Infof("%s labeled with run shaper test label \n", getReqID())
				labelMap["shaper"] = true
				bambooLabel = "shaper_label"
			default:
				// so there are some unknown labels
				// we will accept query but wont invoke any bamboo endpoints
				log.Warningf("%s Labeled action with unknown label: %s, skipping... \n", getReqID(), payload.Label.Name)
				return genResponse(http.StatusOK, "Unsupported label received")
			}
		}
		// pass payload to bamboo trigger func
		// most work to generate POST query to bamboo endpoint will be made there
		if err := handlePullRequest(payload); err != nil {
			// most common reason to get an error
			// is get pull request from unsupported repo (not in projectMap)
			// but there are possible errors connected to bamboo POST request
			log.Errorf("%s %s \n", getReqID(), err)
			skypeMessage := fmt.Sprintf("(shock) Middleware Error: %s, %s", err, getReqID())
			log.Infof("%s Notifying users via skype \n", getReqID())
			if isDaylight() {
				sendSkypeMessage(skypeMessage)
			}
			return genResponse(http.StatusOK, err.Error())
		}
		// Successfull exit from lambda func is here
		return genResponse(http.StatusOK, "bamboo was invoked")
	}
	// Action specified in pull request not supported
	// but we still return 200 ok status code for github
	log.Warningf("%s Unsupported pull request action: %s \n", getReqID(), payload.Action)
	return genResponse(http.StatusOK, "Unsupported action")
}

func handlePullRequest(p *PullRequestPayload) error {
	plan, err := getPlan(p)
	if err != nil {
		return err
	}
	// make http POST request to bamboo and return
	// nil (which is success) or error (if request to bamboo failed)
	// Note that now default job will alway be triggered
	// AM-RTSHO or AER-RTSHO
	errChan := make(chan error, 0)
	go func() {
		var err error
		for i := 0; i < 3; i++ {
			err = makeBambooPostReq(plan, p)
			if err != nil {
				//intercept errors from bambbo
				log.Warningf("%s Attempt number %d to invoke Bamboo API failed \n", getReqID(), i+1)
				if i != 2 {
					//no need to sleep during last iteration
					// only on first 2
					time.Sleep(7 * time.Second)
				}
			} else {
				log.Debugf("%s Bamboo API was successfully invoked from %d attempt \n", getReqID(), i+1)
				break
			}
		}
		errChan <- err
	}()
	select {
	case <-time.After(25 * time.Second):
		return fmt.Errorf("Timeout reached. Bamboo connection timeout")
	case resp := <-errChan:
		return resp
	}

}

func getProject(s string) string {
	p := strings.Split(s, "-")[0]
	for k, v := range projectMap {
		if v == p {
			return k
		}
	}
	return ""
}

func getPlan(p *PullRequestPayload) (string, error) {
	project, ok := projectMap[p.PullRequest.Head.Repo.FullName]
	if !ok {
		// as already was mentioned this is most common error exit from func
		// pull request from repo we are not interested in
		log.Warningf("%s Unsupported project \n", getReqID())
		return "", fmt.Errorf("Unsupported repo")
	}
	// plan is part of bamboo url path
	// here we are defining default one, proabably it will be rewrite in next sections
	plan := project + BambooPlanPostfix

	// Labels will rewrite default plan
	// according label-job reference in bamboo
	for label, ok := range labelMap {
		if ok {
			// if resterated plan = AEI-
			plan = fmt.Sprintf("%s-%s", project, postfixMap[label])
			log.Infof("%s %s test detected, rewriting default plan to: %s \n", getReqID(), label, plan)
			break
		}
	}
	return plan, nil
}

func genResponse(code int, body string) (events.APIGatewayProxyResponse, error) {
	headers := map[string]string{"content-type": "text/html"}
	response := events.APIGatewayProxyResponse{StatusCode: code, Body: body, Headers: headers}
	return response, nil
}

func getSignature(input, key string) string {
	key_for_sign := []byte(key)
	h := hmac.New(sha1.New, key_for_sign)
	h.Write([]byte(input))
	bs := h.Sum(nil)
	return fmt.Sprintf("sha1=%x", bs)
}

func getReqID() string {
	// we need this to get elasticsearch log ordered by time
	// because a lot of log messages has identical timestamp up to milliseconds
	// so with waiting for 1 ms we will ensure we have diff timestamps
	<-time.After(1 * time.Millisecond)
	// just return global var after awaiting
	return reqID
}
func isDaylight() bool {
	n := time.Now().Hour()
	if n >= 6 && n <= 20 {
		return true
	}
	return false
}

func main() {
	lambda.Start(PostHandler)
}
