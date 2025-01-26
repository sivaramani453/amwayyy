package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"sync"
	"time"
)

const (
	PayloadType = "application/json"
)

type ZabbixAPI struct {
	sync.Mutex
	url   string
	token string
	pool  chan bool
}

func (z *ZabbixAPI) bindWorker() error {
	// this op will block if chan contains items = it's capacity
	// this means that other goroutines works with api
	done := make(chan bool, 0)
	go func(c chan bool) {
		z.pool <- true
		done <- true
	}(done)

	for i := 0; i < 120; i++ {
		select {
		case <-done:
			return nil
		case <-time.After(500 * time.Millisecond):
			continue
		}
	}
	// 60s timeout to get free worker
	return fmt.Errorf("it seems to be all workers are busy for too long")
}

func (z *ZabbixAPI) releaseWorker() {
	// get 1 item from pool chan
	<-z.pool
}

func (z *ZabbixAPI) auth(u, p string) error {
	method := "user.login"

	params := ZabbixParams{"user": u, "password": p}
	response, err := z.makeQuery(method, params)
	if err != nil {
		return err
	}

	token, ok := response.(string)
	if !ok {
		return fmt.Errorf("Could not get zabbix token")
	}
	z.token = token
	return nil
}

func (z *ZabbixAPI) makeQuery(method string, params interface{}) (interface{}, error) {
	zr := ZabbixRequest{ID: 1, JsonRPC: "2.0", Method: method, Auth: z.token}

	zr.Params = params

	jsonObj, err := json.Marshal(zr)
	if err != nil {
		return nil, err
	}

	// API Call (z.pool capacity is max parallel api calls)
	// z.bindWorker() blocking for a while procedure
	if err := z.bindWorker(); err != nil {
		return nil, err
	}
	resp, err := http.Post(z.url, PayloadType, bytes.NewReader(jsonObj))
	if err != nil {
		return nil, err
	}
	z.releaseWorker()
	defer resp.Body.Close()

	zresp := new(ZabbixResponse)
	err = json.NewDecoder(resp.Body).Decode(zresp)
	if err != nil {
		return nil, err
	}
	if zresp.Error != nil {
		return nil, fmt.Errorf("Error code: %d. %s %s", zresp.Error.Code, zresp.Error.Message, zresp.Error.Data)
	}
	return zresp.Result, nil
}

func NewZabbixAPI(url, user, pwd string, c int) (*ZabbixAPI, error) {
	pw := make(chan bool, c)

	z := new(ZabbixAPI)
	z.pool = pw
	z.url = url

	if err := z.auth(user, pwd); err != nil {
		return nil, err
	}
	return z, nil
}
