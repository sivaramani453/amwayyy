package github

import (
	"crypto/tls"
	"net/http"
	"time"
)

var (
	// Set global client with reasonable timeouts
	// Client is goroutine safe.
	tr = &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: false},
	}
	httpClient = &http.Client{Transport: tr, Timeout: 5 * time.Second}
)
