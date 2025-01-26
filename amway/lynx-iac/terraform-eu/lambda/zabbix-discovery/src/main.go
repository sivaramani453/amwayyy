package main

import (
	"os"
	"strings"
	"sync"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/pymhd/go-logging"
	"github.com/pymhd/go-logging/handlers"
)

const (
	ZabbixWorkers    = 50
	ZabbixAPIWorkers = 5
)

var (
	reqID               string
	zURL                = os.Getenv("ZABBIX_URL")
	zUser               = os.Getenv("ZABBIX_USER")
	zPassword           = os.Getenv("ZABBIX_PASSWORD")
	zActionWhenMissing  = os.Getenv("WHEN_MISSING")
	defaultGroupList    = []string{"AWS Discovered Hosts"}
	defaultTemplateList = []string{"Template OS Linux"}
	ZabbixHosts         map[string]*Instance
	// global logger
	log = logger.New("main", handlers.StreamHandler{}, logger.DEBUG, logger.OTIME|logger.OLEVEL)
)

func eventHandler(e events.CloudWatchEvent) {
	reqID = e.ID
	// check env vars or panic
	MustValidateVars()
	// connect to zabbix, exit if fail
	zbx, err := NewZabbixAPI(zURL, zUser, zPassword, ZabbixAPIWorkers)
	if err != nil {
		log.Errorf("%s Could not connect to zabbix API: %s\n", reqID, err)
		panic(err)
	}
	log.Debugf("%sSuccessfuly obtained auth token for zabbix\n", reqID)
	//chan to pass to goroutine to add/update hosts in zabbix
	instancesChan := make(chan *Instance, 0)
	wasteInstancesChan := make(chan string, 0)
	// spawn workers
	var wg sync.WaitGroup
	for i := 0; i < ZabbixWorkers; i++ {
		wg.Add(1)
		go zabbixInstanceHandler(instancesChan, wasteInstancesChan, zbx, &wg)
	}
	// spawn closure that will safely delete
	// hosts from ZabbixHosts global map
	deletionDone := make(chan bool, 0)
	go func() {
		var names []string
		for name := range wasteInstancesChan {
			names = append(names, name)
		}
		// when wasteInstancesChan will be closed this would mean then all
		// zabbix instance hadlers workers are done and no one reads global var anymore
		for _, name := range names {
			delete(ZabbixHosts, name)
		}
		// we are done here, unblock main process
		deletionDone <- true
	}()
	log.Debugf("%s Spawned zabbix goroutines\n", reqID)

	AmazonHosts := GetHostListFromAWS()
	log.Infof("%s Found %d matching hosts in aws\n", reqID, len(AmazonHosts))
	ZabbixHosts, err = zbx.getAllHosts()
	if err != nil {
		log.Errorf("%s Could not get list of all hosts in zabbix: %s\n", reqID, err)
		panic(err)
	}
	log.Infof("%s Found %d tagged hosts in zabbix\n", reqID, len(ZabbixHosts))

	// add hosts to chan where they will be fetched by goroutines and proceeded
	for _, h := range AmazonHosts {
		log.Debugf("%s Pushing to worker: ip %s, name %s, aws id %s\n", reqID, h.IP, h.Name, h.AmazonID)
		instancesChan <- h.Validate()
	}
	close(instancesChan)
	wg.Wait()
	close(wasteInstancesChan)
	<-deletionDone
	// delete/disable rest of hosts
	zabbixLeftoversHandler(zbx)
}

func zabbixInstanceHandler(in chan *Instance, out chan string, zbx *ZabbixAPI, wg *sync.WaitGroup) {
	defer wg.Done()

	for host := range in {
		log.Infof("%s Going to add aws host %s %s to zabbix server.\n", reqID, host.AmazonID, host.Name)
		zabbixHost, ok := ZabbixHosts[host.Name]
		if ok {
			log.Infof("%s Host %s already exist, detecting any diff\n", reqID, host.Name)
			groupsEqual := sliceContentEqual(host.Groups, zabbixHost.Groups)
			templatesEqual := sliceContentEqual2(host.Templates, zabbixHost.Templates)
			var update bool
			switch {
			case !groupsEqual:
				a := strings.Join(host.Groups, ", ")
				z := strings.Join(zabbixHost.Groups, ", ")
				log.Infof("%s Groups discovered in aws and zabbix server does not match for %s. AWS tags: '%s', Zabbix Server: '%s'. Host will be updated\n", reqID, host.Name, a, z)
				update = true
			case !templatesEqual:
				a := strings.Join(host.Templates, ", ")
				z := strings.Join(zabbixHost.Templates, ", ")
				log.Infof("%s Templates discovered in aws and zabbix server does not match for %s. AWS tags: '%s', Zabbix Server: '%s'. Host will be updated\n", reqID, host.Name, a, z)
				update = true
			case zabbixHost.ZabbixStatus != "0":
				log.Infof("%s Host %s discoverd in aws but disabled in Zabbix Server. Host will be updated.\n", reqID, host.Name)
				update = true
			default:
				log.Debugf("%s Nothing changed for host %s, skipping\n", reqID, host.Name)
			}

			if update {
				host.ZabbixID = ZabbixHosts[host.Name].ZabbixID
				host.ZabbixStatus = "0"
				AddOrUpdateZabbixHost(host, zbx, true)
			}
			out <- host.Name
		} else {
			AddOrUpdateZabbixHost(host, zbx, false)
		}
	}
}

func zabbixLeftoversHandler(zbx *ZabbixAPI) {
	var hostnames []string
	var hostids []string
	for name, instance := range ZabbixHosts {
		if instance.ZabbixStatus == "0" {
			hostids = append(hostids, instance.ZabbixID)
			hostnames = append(hostnames, name)
		}
	}

	switch zActionWhenMissing {
	case "disable":
		if len(hostnames) > 0 {
			log.Infof("%s Instances that are no longer present on aws but still exist in zabbix:  '%s'. Will be disabled.\n", reqID, strings.Join(hostnames, ", "))
			err := zbx.updateHostsStatus(hostids, "1")
			if err != nil {
				log.Errorf("%s %s\n", reqID, err)
			}
		} else {
			log.Infof("%s All instances in zabbix present in aws, no leftovers.", reqID)
		}
	case "delete":
		log.Infof("%s Instances that are no longer present on aws but still exist in zabbix:  '%s'. Will be deleted (not implemented yet).\n", reqID, strings.Join(hostnames, ", "))
	default:
		log.Infof("%s Instances that are no longer present on aws but still exist in zabbix:  '%s'. No action specified for such case, doing nothing.\n", reqID, strings.Join(hostnames, ", "))
	}
}

func AddOrUpdateZabbixHost(host *Instance, zbx *ZabbixAPI, exist bool) {
	// Proceed with templates
	if len(host.Templates) == 0 {
		log.Warningf("%s No templates specified for host: %s, default template (os linux) will be used\n", reqID, host.Name)
		host.Templates = defaultTemplateList
	}
	// get list of discovered templateids by its names
	templateIDs, err := zbx.getTemplateIds(host.Templates)
	if err != nil {
		log.Errorf("%s %s\n", reqID, err)
		return
	}
	if len(templateIDs) == 0 {
		// Maybe use default template in this case too... IDK
		log.Errorf("%s Could not find any matching templates for host: %s %s\n", reqID, host.AmazonID, host.Name)
		return
	}
	log.Infof("%s Discovered next templateids: %s to attach to host %s\n", reqID, strings.Join(templateIDs, ","), host.Name)
	// Proceed with groups now
	if len(host.Groups) == 0 {
		log.Warningf("%s No groups specified for host: %s, default group will be used\n", reqID, host.Name)
		host.Groups = defaultGroupList
	}
	// Get list of discovered/created groupids by names
	groupids, err := zbx.getOrCreateGroups(host.Groups)
	if err != nil {
		log.Errorf("%s %s\n", reqID, err)
		return
	}
	log.Infof("%s Discovered next groupids: %s to attach to host %s\n", reqID, strings.Join(groupids, ","), host.Name)

	// now create or update  host in zabbix in discovered/created groups and attach templates
	if !exist {
		hostID, err := zbx.createNewHost(host.Name, host.IP, host.ZabbixPort, groupids, templateIDs, host.JMX, host.JMXPort)
		if err != nil {
			log.Errorf("%s %s\n", reqID, err)
			return
			log.Infof("%s %s created with zabbix id: %s\n", reqID, host.Name, hostID)
		}
		return
	}
	err = zbx.updateHost(host.ZabbixID, host.ZabbixStatus, groupids, templateIDs)
	if err != nil {
		log.Errorf("%s Could not update host %s: %s\n", reqID, host.Name, err)
	}
}

func main() {
	lambda.Start(eventHandler)
}
