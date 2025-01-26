package main

// 		was wfs removed
// 		updateProd:       "run_update_prod_test.yaml",
//		updateFull:       "run_update_full_test.yaml",
// 		initReg:          "run_init_test.yaml",
//		initLite:         "run_init_lite_test.yaml",
// 		sonarEntCC:       "run_sonar_ent_test_cc.yaml",
// 		sonarEntDev:	  "run_sonar_ent_dev_test.yaml",
//		sonar:            "run_sonar_test.yaml",
// 		intergrationLite: "run_integration_lite_test.yaml",
//
// removed labels 
// 	updateProd       = "run update test prod"
// 	updateFull       = "run update test full"
// 	initReg          = "run init test"
// 	initLite         = "run init-lite test"
// 	sonarEntCC       = "run ent sonar test cc"
// 	sonarEntDev      = "run ent sonar dev test"
// 	sonar            = "run sonar test"
// 	intergrationLite = "run integration-lite test"


const (
	build1            = "t: build"
	update1           = "t: update"
	initUI1           = "t: unit + ui"
	unitWeb1          = "t: unit + web"
	spring1           = "t: spring"
	sonarEnt1         = "t: sonar"
	intergration1     = "t: integration"

	build            = "run build test"
	update           = "run update test"
	initUI           = "run ui unit test"
	unitWeb          = "run unit + web test"
	spring           = "run spring test"
	sonarEnt         = "run ent sonar test"
	intergration     = "run integration test"
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
		"eujmws5": true, 
	}

	// Contexts related vars
	europeCtx = []string{
		"Build + JSP tests",
		"Spring context test",
		"UI Unit tests",
		"Unit + Web tests",
		"Sonar Ent test",
		"Integration test part 1",
		"Integration test part 2",
		"Update test",
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
		build1:            "run_build_test.yaml",
		update1:           "run_update_test.yaml",
		initUI1:           "run_init_ui_lite.yaml",
		unitWeb1:          "run_unit_web_test.yaml",
		spring1:           "run_spring_test.yaml",
		sonarEnt1:         "run_sonar_ent_test.yaml",
		intergration1:     "run_integration_test.yaml",
		build:            "run_build_test.yaml",
		update:           "run_update_test.yaml",
		initUI:           "run_init_ui_lite.yaml",
		unitWeb:          "run_unit_web_test.yaml",
		spring:           "run_spring_test.yaml",
		sonarEnt:         "run_sonar_ent_test.yaml",
		intergration:     "run_integration_test.yaml",
		restart:          "run_all_tests.yaml",
	}
)
