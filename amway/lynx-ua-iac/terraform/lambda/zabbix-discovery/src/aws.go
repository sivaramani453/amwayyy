package main

import (
	"os"
	"strings"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
)

const (
	SearchTagKey             = "tag:zabbix"
	SearchTagValue           = "true"
	SearchInstanceStateName  = "instance-state-name"
	SearchInstanceStateValue = "running"
	DefaultZabbixPort        = "10050"
	DefaultJMXPort           = "9004"
)

var (
	defaultRegion = "eu-central-1"
)

func (i *Instance) Validate() *Instance {
	// delete all empty groups from slice
	// empty values can happen for instance if tag ends with comma
	// or have some extra comma between values, so this is just to
	// avoid zabbix group/template discover with empty filter (cuz in such case zabbix will returmn all his objects)
	emptyIndexes := make([]int, 0)
	for n, g := range i.Groups {
		if g == "" {
			emptyIndexes = append(emptyIndexes, n)
		}
	}
	if ec := len(emptyIndexes); ec > 0 {
		log.Warningf("%s Found %d empty group names in aws tags, fix it or not, whatever\n", reqID, ec)
	}
	// you may ask why i var
	// if we deleted some index from slice, next id of empty obj in slice will decrease by 1
	// so i needed to consider this
	for c, n := range emptyIndexes {
		i.Groups = append(i.Groups[:n-c], i.Groups[n-c+1:]...)
	}
	// repeat for templates
	emptyIndexes = []int{}
	for n, g := range i.Templates {
		if g == "" {
			emptyIndexes = append(emptyIndexes, n)
		}
	}
	if ec := len(emptyIndexes); ec > 0 {
		log.Warningf("%s Found %d empty template names in aws tags, fix it or not, whatever\n", reqID, ec)
	}
	for c, n := range emptyIndexes {
		i.Templates = append(i.Templates[:n-c], i.Templates[n-c+1:]...)
	}
	if len(i.Groups) == 0 {
		i.Groups = defaultGroupList
	}
	if len(i.Templates) == 0 {
		i.Templates = defaultTemplateList
	}
	return i
}

func getHostListFromAWS() *ec2.DescribeInstancesOutput { //[]*Instance {
	//create aws session (ec2 role required)
	region := defaultRegion
	if r := os.Getenv("AWS_REGION"); len(r) > 0 {
		region = r
	}
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region)},
	)
	// Create new EC2 client
	ec2Svc := ec2.New(sess)
	// get aws instances based on tags key value: zabbix=true
	input := &ec2.DescribeInstancesInput{
		Filters: []*ec2.Filter{
			{
				Name: aws.String(SearchTagKey),
				Values: []*string{
					aws.String(SearchTagValue),
				},
			},
			{
				Name: aws.String(SearchInstanceStateName),
				Values: []*string{
					aws.String(SearchInstanceStateValue),
				},
			},
		},
	}

	result, err := ec2Svc.DescribeInstances(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			default:
				log.Errorf("%s %s\n", reqID, aerr.Error())
			}
		} else {
			// Message from an error.
			log.Errorf("%s %s\n", reqID, err.Error())
		}

	}
	return result
}

func GetHostListFromAWS() []*Instance {
	input := getHostListFromAWS()
	// create slice of hosts and append discovered instances
	// based on name and tags related to zabbix (templates and groups)
	hosts := make([]*Instance, 0)
	for _, reserv := range input.Reservations {
		for _, instance := range reserv.Instances {
			host := createInstance(instance)
			hosts = append(hosts, host)
		}
	}
	return hosts
}

func createInstance(i *ec2.Instance) *Instance {
	host := new(Instance)
	host.IP = *i.PrivateIpAddress 
	host.AmazonID = *i.InstanceId 
	host.ZabbixPort = DefaultZabbixPort
	host.JMXPort = DefaultJMXPort

	for _, tag := range i.Tags {
		switch *tag.Key {
		case "Name":
			host.Name = *tag.Value
		case "zabbix_templates":
			templates := strings.Split(*tag.Value, ",")
			// delete every trailing space in every item
			trimSlice(templates)
			host.Templates = templates
		case "zabbix_groups":
			groups := strings.Split(*tag.Value, ",")
			// delete every trailing space in every item
			trimSlice(groups)
			host.Groups = groups
		case "zabbix_port":
			host.ZabbixPort = *tag.Value
		case "jmx_port":
			host.JMXPort = *tag.Value
		case "zabbix_jmx":
			isEnabled := *tag.Value
			if isEnabled == "true" || isEnabled == "1" || isEnabled == "t" {
				host.JMX = true
			}
		}
	}
	return host
}

func trimSlice(l []string) {
	for i, s := range l {
		l[i] = strings.Trim(s, " ")
	}
}
