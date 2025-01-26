package main

import (
	"os"
	"bytes"
	"compress/gzip"
	"encoding/base64"
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"io/ioutil"

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
	uploadLogs(lm)
	// Do i really need this?
	return nil
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
