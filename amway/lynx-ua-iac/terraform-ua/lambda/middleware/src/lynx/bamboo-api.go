package main

import (
	"os"
	"crypto/tls"
	"fmt"
	"net/http"
	"strconv"
)


func makeBambooPostReq(plan string, p *PullRequestPayload) error {
	//create insecure transport (requests.post(verify = False) in python )
	log.Debugf("%s Invoking bamboo API... \n", getReqID())
	insecureTransport := &http.Transport{TLSClientConfig: &tls.Config{InsecureSkipVerify: true}}
	client := &http.Client{Transport: insecureTransport}
	pullNum := strconv.Itoa(p.PullRequest.Number)
	req, err := http.NewRequest("POST", os.Getenv("BAMBOO_URL")+plan, nil)
	if err != nil {
		// not really sure if why this could ever faile but anyway
		log.Errorf("%s %s \n", getReqID(), err)
		return err
	}
	// prepare request details with params
	// and basic auth headers
	req.SetBasicAuth(os.Getenv("BAMBOO_USER"), os.Getenv("BAMBOO_PASSWORD"))
	q := req.URL.Query()
	q.Add("bamboo.variable.pull_num", pullNum)
	q.Add("bamboo.variable.pull_event", p.Action)
	q.Add("bamboo.variable.sender_login", p.Sender.Login)
	q.Add("bamboo.variable.pull_base_ref", p.PullRequest.Base.Ref)
	q.Add("bamboo.variable.pull_ref", p.PullRequest.Head.Ref)
	q.Add("bamboo.variable.pull_sha", p.PullRequest.Head.Sha)
	q.Add("bamboo.variable.label", bambooLabel)
	req.URL.RawQuery = q.Encode()
	//
	log.Debugf("%s Bamboo API endpoint: %s \n", getReqID(), req.URL)
	//return nil
	resp, err := client.Do(req)
	if err != nil {
		log.Errorf("%s %s \n", getReqID(), err)
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		log.Errorf("%s Unsuccessful POST request to bamboo API. StatusCode: %d \n", getReqID(), resp.StatusCode)
		return fmt.Errorf("Bamboo response status code is is not 200 but %d", resp.StatusCode)
	}
	/*
	   bodyText, err := ioutil.ReadAll(resp.Body)
	   if err != nil {
	           log.Errorf("%s %s \n", getReqID(), err)
	           return err
	   }
	   log.Infof("%s Got bamboo response: %s \n", getReqID(), bodyText)
	*/
	log.Infof("%s Successfully made bamboo API call \n", getReqID())
	return nil
}
