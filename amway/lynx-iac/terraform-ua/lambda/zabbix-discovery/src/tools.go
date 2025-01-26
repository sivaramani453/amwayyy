package main

import (
	"sort"
	"strings"
)

func MustValidateVars() {
	if len(zUser) == 0 || len(zPassword) == 0 || !strings.HasPrefix(zURL, "http") {
		log.Errorf("%s Env vars did not set properly\n", reqID)
		panic("env vars error")
	}
}

func sliceContentEqual(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}

	for _, va := range a {
		var met bool
		for i, vb := range b {
			if va == vb {
				met = true
				// delete from  slice for next iterations (if repeated)
				b = append(b[:i], b[i+1:]...)
				break
			}
		}
		if !met {
			return false
		}
	}
	return true
}

func sliceContentEqual2(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}
	sort.Strings(a)
	sort.Strings(b)
	for i, v := range a {
		if b[i] != v {
			return false
		}
	}
	return true
}
