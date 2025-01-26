package main

import (
	"crypto/hmac"
	"crypto/sha1"
	"fmt"
)

func getSignature(input, key string) string {
	bytesKey := []byte(key)
	bytesInput := []byte(input)

	hash := hmac.New(sha1.New, bytesKey)
	hash.Write(bytesInput)
	bs := hash.Sum(nil)

	return fmt.Sprintf("sha1=%x", bs)
}
