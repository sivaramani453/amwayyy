package main

import (
	"fmt"
)

const (
	InventoryTag = "aws-discovery"
)

func (z *ZabbixAPI) hostExist(ip string) bool {
	method := "host.get"

	output := []string{"hostid"}
	ips := []string{ip}
	filter := ZabbixFilter{"ip": ips}
	params := ZabbixHostQueryParams{Filter: filter, Output: output}

	response, err := z.makeQuery(method, params)
	if err != nil {
		log.Warningf("%s %s\n", reqID, err)
		return true
	}
	hl := response.([]interface{})
	if len(hl) > 0 {
		return true
	}
	return false
}

func (z *ZabbixAPI) getAllHosts() (map[string]*Instance, error) {
	method := "host.get"

	params := ZabbixHostQueryParams{}
	params.Output = []string{"status", "host"}
	params.SelectInventory = []string{"tag"}
	params.SearchInventory = ZabbixInventory{"tag": InventoryTag}
	params.SelectGroups = "extend"
	params.SelectParentTemplates = []string{"name"}

	response, err := z.makeQuery(method, params)
	if err != nil {
		return nil, err
	}
	hosts, ok := response.([]interface{})
	if !ok {
		return nil, fmt.Errorf("Type assertion failed to get list of host objects. Expected []interface{}. Got: %T", response)
	}
	result := make(map[string]*Instance, 0)

	for _, h := range hosts {
		// init zabbix host item
		host, _ := h.(map[string]interface{})
		hostname, _ := host["host"].(string)
		hostID, _ := host["hostid"].(string)
		status, _ := host["status"].(string)
		zh := &Instance{Name: hostname, ZabbixID: hostID, ZabbixStatus: status}
		// add groups
		grouplist, _ := host["groups"].([]interface{})
		for _, groupObj := range grouplist {
			group := groupObj.(map[string]interface{})
			groupName := group["name"].(string)
			zh.Groups = append(zh.Groups, groupName)
		}
		// add templates parentTemplates
		templatelist, _ := host["parentTemplates"].([]interface{})
		for _, templateObj := range templatelist {
			template := templateObj.(map[string]interface{})
			templateName := template["name"].(string)
			zh.Templates = append(zh.Templates, templateName)
		}
		result[hostname] = zh
	}
	return result, nil
}

func (z *ZabbixAPI) createNewHost(hostname, ip, zabbixPort string, groups, templates []string, JMXEnabled bool, JMXPort string) (string, error) {
	method := "host.create"

	host := ZabbixHost{}
	host.Name = hostname
	host.Interfaces = make([]ZabbixHostInterface, 0)
	host.Inventory = ZabbixInventory{"tag": InventoryTag}

	// Add interfaces
	ZbxIface := ZabbixHostInterface{Type: 1, Main: 1, UseIP: 1, IP: ip, Port: zabbixPort}
	host.Interfaces = append(host.Interfaces, ZbxIface)
	if JMXEnabled {
		JMXIface := ZabbixHostInterface{Type: 4, Main: 1, UseIP: 1, IP: ip, Port: JMXPort}
		host.Interfaces = append(host.Interfaces, JMXIface)
	}
	// Add groups
	for _, gid := range groups {
		host.Groups = append(host.Groups, map[string]string{"groupid": gid})
	}
	// Add templates
	for _, tid := range templates {
		host.Templates = append(host.Templates, map[string]string{"templateid": tid})
	}

	response, err := z.makeQuery(method, host)
	if err != nil {
		return "", err
	}
	hosts, ok := response.(map[string]interface{})
	if !ok {
		return "", fmt.Errorf("First type assertion failed for host.create. Expected map[string]interface{}, got %T", response)
	}
	hostids, ok := hosts["hostids"].([]interface{})
	if !ok {
		return "", fmt.Errorf("Second type assertion failed for host.create. Expected []interface{}, got %T", hosts["hostids"])
	}
	if len(hostids) == 0 {
		return "", fmt.Errorf("Empty host ids list received from zabbix API for host.create method")
	}
	hostid := hostids[0].(string)
	return hostid, nil
}

func (z *ZabbixAPI) updateHost(id, status string, groups, templates []string) error {
	method := "host.update"

	host := ZabbixHost{ID: id, Status: status}
	// Add groups
	for _, gid := range groups {
		host.Groups = append(host.Groups, map[string]string{"groupid": gid})
	}
	// Add templates
	for _, tid := range templates {
		host.Templates = append(host.Templates, map[string]string{"templateid": tid})
	}

	_, err := z.makeQuery(method, host)
	return err
}

func (z *ZabbixAPI) updateHostsStatus(ids []string, status string) error {
	method := "host.massupdate"
	params := ZabbixHostQueryParams{Status: status}
	for _, id := range ids {
		params.Hosts = append(params.Hosts, ZabbixHostParam{"hostid": id})
	}

	_, err := z.makeQuery(method, params)
	return err
}

func (z *ZabbixAPI) getTemplateIds(templates []string) ([]string, error) {
	var result []string
	method := "template.get"

	filter := ZabbixFilter{"host": templates}
	output := []string{"templateid"}
	params := ZabbixHostQueryParams{Filter: filter, Output: output}

	response, err := z.makeQuery(method, params)
	if err != nil {
		return result, err
	}
	templateList, ok := response.([]interface{})
	if !ok {
		return result, fmt.Errorf("Type assertion failed for template.get. Expected []interface{}, got: %T", response)
	}
	for _, t := range templateList {
		templateID := t.(map[string]interface{})
		id := templateID["templateid"].(string)
		// check previous 2 type assertions
		// if failed still we have to iterate over all templates
		if id != "" {
			result = append(result, id)
		}
	}
	return result, nil
}

func (z *ZabbixAPI) getOrCreateGroups(groups []string) ([]string, error) {
	// we need this lock because few gouroutines can start
	// start group creating process if they simultaneously wont find desired host group
	z.Lock()
	defer z.Unlock()

	var result []string

	for _, groupname := range groups {
		gid := z.getGroupID(groupname)
		if len(gid) > 0 {
			// group found, all good, go to next group in list
			result = append(result, gid)
			continue
		}
		// group not found, create
		ngid, err := z.createNewGroup(groupname)
		if err != nil {
			// Then what, cancel operation or ignore...
			// for now just ignore failed group
			continue
		}
		result = append(result, ngid)
	}
	return result, nil
}

func (z *ZabbixAPI) getGroupID(group string) string {
	method := "hostgroup.get"
	filter := ZabbixFilter{"name": []string{group}}
	output := []string{"extend"}
	params := ZabbixGroupQueryParams{Filter: filter, Output: output}

	response, err := z.makeQuery(method, params)
	if err != nil {
		return ""
	}

	groupList, _ := response.([]interface{})
	if len(groupList) > 0 {
		groupObj := groupList[0].(map[string]interface{})
		groupID := groupObj["groupid"].(string)
		return groupID
	}
	return ""
}

func (z *ZabbixAPI) createNewGroup(group string) (string, error) {
	method := "hostgroup.create"
	params := ZabbixParams{"name": group}

	response, err := z.makeQuery(method, params)
	if err != nil {
		return "", err
	}

	groupObj, _ := response.(map[string]interface{})
	groupList, _ := groupObj["groupids"].([]interface{})
	if len(groupList) > 0 {
		groupID, _ := groupList[0].(string)
		if len(groupID) > 0 {
			return groupID, nil
		}
	}
	return "", fmt.Errorf("Could not get groupid in response for hostgroup.create method")
}
