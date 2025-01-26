package main

import (
	"crypto/tls"
	"net/http"
	"sync"
	"time"
)

type uploader func(LogEvent) error
type SplunkPayload struct {
	Event LogEvent `json:"event"`
}

var (
	client    *http.Client
	uploaders = make(map[string]uploader)
)

func init() {
	// set global client with reasonable timeout
	// http.Client is thread safe object
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	client = &http.Client{Transport: tr, Timeout: 10 * time.Second}
}

func uploadLogs(lm *LogMessage) {
	//prepare input streams for workers
	var wg sync.WaitGroup
	c := make(chan LogEvent, 0)
	// spawn workers
	for i := 0; i < 5; i++ {
		wg.Add(1)
		go runCurlWorker(c, &wg)
	}
	// push data to workers
	for _, le := range lm.LogEvents {
		// This is tricky way to push bucket name to elk uploader
		// because it calculates index based on this
		// Splunk uploader will just ignore this field
		le.LogGroup = lm.LogGroup
		// Push to workers
		c <- le
	}
	// wait for workers
	close(c)
	wg.Wait()
}

func runCurlWorker(c chan LogEvent, wg *sync.WaitGroup) {
	defer wg.Done()

	for le := range c {
		if err := uploaders[destination](le); err != nil {
			// no need to panic or smth
			// just log it for future investigation
			log.Error(err)
		}
	}
}
