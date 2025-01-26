package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"os"
)

const (
	ver         = "1.0.0"
	simpleType  = "simple"
	contentType = "application/json"
	skypeURL    = "https://touch.epm-esp.projects.epam.com/bot-esp/message"
)

var (
	skypeSecret = os.Getenv("SKYPE_SECRET")
	channel     = os.Getenv("SKYPE_CHAT_ID")
)

type skypeMessage struct {
	Channel string `json:"channel"`
	Secret  string `json:"secret"`
	Type    string `json:"type"`
	Text    string `json:"text"`
}

func sendSkypeMessage(msg string) error {
	sm := skypeMessage{
		Text:    msg,
		Secret:  skypeSecret,
		Channel: channel,
		Type:    simpleType,
	}
	p, _ := json.Marshal(sm)
	payload := bytes.NewReader(p)

	client := &http.Client{}
	req, _ := http.NewRequest(http.MethodPost, skypeURL, payload)
	req.Header.Add("accept-version", ver)
	req.Header.Add("content-type", contentType)

	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	resp.Body.Close()
	return nil
}
