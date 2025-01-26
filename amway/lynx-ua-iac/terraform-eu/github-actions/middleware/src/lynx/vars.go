package main

const (
	build            = "run build test"
	update           = "run update test"
	updateProd       = "run update test prod"
	updateFull       = "run update test full"
	initReg          = "run init test"
	initUI           = "run ui unit test"
	initLite         = "run init-lite test"
	unitWeb          = "run unit + web test"
	spring           = "run spring test"
	sonar            = "run sonar test"
	sonarEnt         = "run ent sonar test"
	sonarEntDev      = "run ent sonar dev test"
	sonarEntCC       = "run ent sonar test cc"
	intergration     = "run integration test"
	intergrationLite = "run integration-lite test"
	merge            = "merge it"
	restart          = "RESTARTED"

	TestRepo       = "AmwayACS/lynx-test"
	EuropeRepo     = "AmwayACS/lynx"
	EuropeConfRepo = "AmwayACS/lynx-config"
)

var (
	// Users related vars
	serviceUsers = map[string]bool{
		"eujjzu8": true,
		"eujkjq9": true,
	}

	// Contexts related vars
	europeCtx = []string{
		"Build + JSP tests",
		"Spring context test",
		"UI Unit tests",
		"Unit + Web tests",
		"Sonar Ent test",
	}

	europeConfCtx = []string{}

	ctxMap = map[string][]string{
		TestRepo:	europeCtx,
		EuropeRepo:     europeCtx,
		EuropeConfRepo: europeConfCtx,
	}

	// Labels related vars
	serviceLabelMap = map[string]bool{
		merge:   true,
		restart: true,
	}
	userLabelMap = map[string]string{
		build:            "run_build_test.yaml",
		update:           "run_update_test.yaml",
		updateProd:       "run_update_prod_test.yaml",
		updateFull:       "run_update_full_test.yaml",
		initReg:          "run_init_test.yaml",
		initUI:           "run_init_ui_lite.yaml",
		initLite:         "run_init_lite_test.yaml",
		unitWeb:          "run_unit_web_test.yaml",
		spring:           "run_spring_test.yaml",
		sonar:            "run_sonar_test.yaml",
		sonarEnt:         "run_sonar_ent_test.yaml",
		sonarEntDev:	  "run_sonar_ent_dev_test.yaml",
		sonarEntCC:       "run_sonar_ent_test_cc.yaml",
		intergration:     "run_integration_test.yaml",
		intergrationLite: "run_integration_lite_test.yaml",
		restart:          "run_all_tests.yaml",
	}
)
