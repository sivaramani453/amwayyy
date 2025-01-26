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
	intergration     = "run integration test"
	intergrationLite = "run integration-lite test"
	merge            = "merge it"
	restart          = "RESTARTED"

	TestRepoRU     = "AmwayACS/lynx-ci-tests-ru"
	TestRepo       = "AmwayACS/lynx-ci-tests"
	EuropeRepo     = "AmwayACS/lynx"
	EuropeConfRepo = "AmwayACS/lynx-config"
	RussiaRepo     = "AmwayACS/lynx-ru"
	RussiaConfRepo = "AmwayACS/lynx-ru-config"
)

var (
	// Users related vars
	serviceUsers = map[string]bool{
		"eujjzu8": true,
		"eujkjq9": true,
		"pymhd":   true,
	}

	// Contexts related vars
	europeCtx = []string{
		"Build + JSP tests",
		"Spring test",
		"UI Unit test",
		"Unit + Web tests",
		"Sonar Ent test",
	}
	russiaCtx = []string{
		"Build + JSP tests",
		"Sonar Ent test",
		"Spring test",
		"UI Unit test",
		"Unit + Web tests",
		"Update test",
		"Integration tests part 1",
		"Integration tests part 2",
	}
	europeConfCtx = []string{}
	russiaConfCtx = []string{}

	ctxMap = map[string][]string{
		TestRepoRU:     russiaCtx,
		TestRepo:	europeCtx,
		EuropeRepo:     europeCtx,
		RussiaRepo:     russiaCtx,
		EuropeConfRepo: europeConfCtx,
		RussiaConfRepo: russiaConfCtx,
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
		intergration:     "run_integration_test.yaml",
		intergrationLite: "run_integration_lite_test.yaml",
		restart:          "run_all_tests.yaml",
	}
)
