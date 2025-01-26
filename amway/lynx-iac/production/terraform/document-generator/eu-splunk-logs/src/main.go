package main

import (
	"bytes"
	"compress/gzip"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"io/ioutil"
	"os"

	"github.com/pymhd/go-logging"
	"github.com/pymhd/go-logging/handlers"
)

const (
	defaultDestination = "elk"
)

var (
	destination = os.Getenv("DEST")
	log         = logger.New("main", handlers.StreamHandler{}, logger.DEBUG, logger.OTIME|logger.OLEVEL)
)

type LogMessage struct {
	LogGroup  string     `json:"logGroup"`
	LogEvents []LogEvent `json:"logEvents"`
}

type LogEvent struct {
	ID              string                 `json:"id"`
	Timestamp       int                    `json:"timestamp"`
	Message         string                 `json:"message"`
	ExtractedFields map[string]interface{} `json:"extractedFields"`
	LogGroup        string
}

func handleLogMessage(le events.CloudwatchLogsEvent) error {
	gzipedString := le.AWSLogs.Data
	data, err := proccedData(gzipedString)
	if err != nil {
		log.Error(err)
		return err
	}
	lm := new(LogMessage)
	if err := json.NewDecoder(bytes.NewReader(data)).Decode(lm); err != nil {
		log.Error(err)
		return err
	}
	// This is crazy stuff, i am not the one who is responsible for this
	// I repeat I AM NOT THE ONE WHO IS RESPONSIBLE FOR THIS
	mergeLambdaCalls(lm)
	// Push to elk or splunk based on env var
	uploadLogs(lm)
	
	// Do i really need this?
	return nil
}

func mergeLambdaCalls(lm *LogMessage) {
	logEventsMap := make(map[string]*LogEvent)

	for _, le := range lm.LogEvents {
		//nle := new(LogEvent)
		req := le.ExtractedFields["request_id"]
		reqID := req.(string)
		_, ok := logEventsMap[reqID]
		if !ok {
			nle := new(LogEvent)
			nle.Timestamp = le.Timestamp
			nle.ExtractedFields = make(map[string]interface{})
			nle.ExtractedFields["request_id"] = le.ExtractedFields["request_id"]
			nle.ExtractedFields["timestamp"] = le.ExtractedFields["timestamp"]
			nle.ExtractedFields["event"] = le.ExtractedFields["event"]
			logEventsMap[reqID] = nle
		}
		// logEvent alrerady created
		// we will just update event text
		ts, _ := le.ExtractedFields["timestamp"]
		e, ok := le.ExtractedFields["event"]
		if !ok {
			continue
		}
		eventMessage := logEventsMap[reqID].ExtractedFields["event"]
		eventMessage = fmt.Sprintf("%s\n%s %s\n", eventMessage, ts, e)

		logEventsMap[reqID].ExtractedFields["event"] = eventMessage
	}
	
	// crete new logEvents slice to replace original
	var les []LogEvent
	for _, le := range logEventsMap {
		les = append(les, *le)
	}
	// replace original slice
	lm.LogEvents = les
}

func proccedData(s string) ([]byte, error) {
	//decode base64
	maxBytes := base64.StdEncoding.DecodedLen(len(s))
	buf := make([]byte, maxBytes)
	n, _ := base64.StdEncoding.Decode(buf, []byte(s))
	buf = buf[:n]
	//unzip
	zr, err := gzip.NewReader(bytes.NewReader(buf))
	if err != nil {
		return []byte{}, err
	}
	return ioutil.ReadAll(zr)
}

func init() {
	if len(destination) == 0 {
		destination = defaultDestination
	}
}

func main() {
	lambda.Start(handleLogMessage)
}
