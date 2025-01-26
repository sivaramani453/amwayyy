package main

type Instance struct {
	IP           string
	Name         string
	AmazonID     string
	ZabbixID     string
	ZabbixStatus string
	ZabbixPort   string
	Groups       []string
	Templates    []string
	JMX          bool
	JMXPort      string
}

type ZabbixGroup map[string]string
type ZabbixTemplate map[string]string
type ZabbixInventory map[string]string
type ZabbixParams map[string]interface{}
type ZabbixFilter map[string][]string
type ZabbixHostParam map[string]string

type ZabbixError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
	Data    string `json:"data"`
}

type ZabbixResponse struct {
	Error  *ZabbixError `json:"error"`
	Result interface{}  `json:"result"`
}

type ZabbixRequest struct {
	ID      int         `json:"id"`
	JsonRPC string      `json:"jsonrpc"`
	Auth    string      `json:"auth,omitempty"`
	Method  string      `json:"method,omitempty"`
	Params  interface{} `json:"params,omitempty"`
}

type ZabbixHost struct {
	Status        string                `json:"status,omitempty"`
	ID            string                `json:"hostid,omitempty"`
	Name          string                `json:"host,omitempty"`
	Groups        []ZabbixGroup         `json:"groups,omitempty"`
	Templates     []ZabbixTemplate      `json:"templates,omitempty"`
	Interfaces    []ZabbixHostInterface `json:"interfaces,omitempty"`
	Inventory     ZabbixInventory       `json:"inventory,omitempty"`
	InventoryMode int                   `json:"inventory_mode,omitempty"`
}

type ZabbixHostInterface struct {
	Type  int    `json:"type"`
	Main  int    `json:"main"`
	UseIP int    `json:"useip"`
	DNS   string `json:"dns"`
	IP    string `json:"ip"`
	Port  string `json:"port"`
}

type ZabbixHostQueryParams struct {
	Status                string            `json:"status,omitempty"`
	SelectGroups          string            `json:"selectGroups,omitempty"`
	Output                []string          `json:"output,omitempty"`
	SelectParentTemplates []string          `json:"selectParentTemplates,omitempty"`
	SelectInventory       []string          `json:"selectInventory,omitempty"`
	Hosts                 []ZabbixHostParam `json:"hosts,omitempty"`
	SearchInventory       ZabbixInventory   `json:"searchInventory,omitempty"`
	Filter                ZabbixFilter      `json:"filter,omitempty"`
}

type ZabbixGroupQueryParams struct {
	Output []string     `json:"output"`
	Filter ZabbixFilter `json:"filter,omitempty"`
}
