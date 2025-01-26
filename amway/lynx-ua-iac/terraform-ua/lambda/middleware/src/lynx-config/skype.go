package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"os"
)

const (
	SkypeURL    = "https://touch.epm-esp.projects.epam.com/bot-esp/message"
	ContentType = "application/json"
	SimpleType  = "simple"
)

type skypeMessage struct {
	Channel string `json:"channel"`
	Secret  string `json:"secret"`
	Type    string `json:"type"`
	Text    string `json:"text"`
}

func sendSkypeMessage(msg string) {
	sm := skypeMessage{Channel: os.Getenv("CHAT_ID"), Secret: os.Getenv("SKYPE_SECRET"), Type: SimpleType, Text: msg}
	p, _ := json.Marshal(sm)
	payload := bytes.NewReader(p)

	client := &http.Client{}
	req, err := http.NewRequest("POST", SkypeURL, payload)
	if err != nil {
		log.Errorf("%s %s \n", getReqID(), err)
		return
	}
	req.Header.Add("accept-version", "1.0.0")
	req.Header.Add("content-type", ContentType)
	resp, err := client.Do(req)
	if err != nil {
		log.Errorf("%s %s \n", getReqID(), err)
		return
	}
	resp.Body.Close()
}
