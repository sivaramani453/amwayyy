package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

var (
	splunkURL   = os.Getenv("SPLUNK_URL")
	splunkToken = os.Getenv("SPLUNK_TOKEN")
)

func makeSplunkRequest(le LogEvent) error {
	sp := SplunkPayload{Event: le}
	p, _ := json.Marshal(sp)

	body := bytes.NewReader(p)

	req, err := http.NewRequest(http.MethodPost, splunkURL, body)
	if err != nil {
		return err
	}
	// Set manadatory Auth Header like "Authorization: Splunk XXX-XXX-XXX"
	req.Header.Set("Authorization", "Splunk "+splunkToken)
	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
                // debug
                b, _ := ioutil.ReadAll(resp.Body)
                return fmt.Errorf("ElasticSearch upload request status code is not 200 but %d. Body: %s", resp.StatusCode, string(b))
        }
	return nil
}

func init() {
	uploaders["splunk"] = makeSplunkRequest
}
