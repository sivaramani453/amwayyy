package main

import (
	"net/http"
	"strings"
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
)

const (
	docName = "doc"
	DefaultLogPrefix = "aws-logs-"
)

var (
	elkURL  = os.Getenv("ELK_URL")
)

func makeElkRequest(le LogEvent) error {
	indexName := getIndexName(le.LogGroup)
	url := fmt.Sprintf("%s/%s/%s/", elkURL, indexName, docName)

	p, _ := json.Marshal(le)
	body := bytes.NewReader(p)

	req, err := http.NewRequest("POST", url, body)
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		// debug
		b, _ := ioutil.ReadAll(resp.Body)
		return fmt.Errorf("ElasticSearch upload request status code is not 201 but %d. Body: %s", resp.StatusCode, string(b))
	}
	return nil
}

func getIndexName(s string) string {
	// Buckeet names like /aws/servicenames.../bucketname
	path := strings.Split(s, "/")
	bn := path[len(path)-1]

	// some hardcode for rds
	if bn ==  "postgresql" {
		// rewrite bn with diff value
		bn = path[len(path)-2]
		bn = strings.ReplaceAll(bn, "-", "_")
	}
	index := os.Getenv(bn)
	if len(index) > 0 {
		return index
	}
	return DefaultLogPrefix + strings.ToLower(bn)
}
	
func init() {
	uploaders["elk"] = makeElkRequest
}
