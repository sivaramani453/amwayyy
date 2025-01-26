locals {
  allure_reports_configurations = [
    {
      id      = "amway_fqa_eu_monitoring_bonus"
      enabled = true
      prefix  = "amway_fqa_eu_monitoring_bonus/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "amway_fqa_kz_monitoring"
      enabled = true
      prefix  = "amway_fqa_kz_monitoring/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "amway_fqa_ru_monitoring"
      enabled = true
      prefix  = "amway_fqa_ru_monitoring/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "amway_uat_eu_monitoring"
      enabled = true
      prefix  = "amway_uat_eu_monitoring/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "amway_uat_kz_monitoring"
      enabled = true
      prefix  = "amway_uat_kz_monitoring/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "amway_uat_ru_monitoring"
      enabled = true
      prefix  = "amway_uat_ru_monitoring/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "custom_tests_run"
      enabled = true
      prefix  = "custom_tests_run/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "prod_autotests_monitoring_kz"
      enabled = true
      prefix  = "prod_autotests_monitoring_kz/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "prod_autotests_monitoring_ru"
      enabled = true
      prefix  = "prod_autotests_monitoring_ru/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "prod_autotets_monitoring"
      enabled = true
      prefix  = "prod_autotets_monitoring/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "prod_healthcheck_monitoring"
      enabled = true
      prefix  = "prod_healthcheck_monitoring/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "prod_nodes_monitoring"
      enabled = true
      prefix  = "prod_nodes_monitoring/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "prod_price_rows_monitoring"
      enabled = true
      prefix  = "prod_price_rows_monitoring/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "prod_status_of_index_cj"
      enabled = true
      prefix  = "prod_status_of_index_cj/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_austria"
      enabled = true
      prefix  = "regression_fqa_austria/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_belgium"
      enabled = true
      prefix  = "regression_fqa_belgium/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_denmark"
      enabled = true
      prefix  = "regression_fqa_denmark/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_finland"
      enabled = true
      prefix  = "regression_fqa_finland/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_france"
      enabled = true
      prefix  = "regression_fqa_france/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_germany"
      enabled = true
      prefix  = "regression_fqa_germany/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_italy"
      enabled = true
      prefix  = "regression_fqa_italy/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_kz"
      enabled = true
      prefix  = "regression_fqa_kz/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_netherlands"
      enabled = true
      prefix  = "regression_fqa_netherlands/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_norway"
      enabled = true
      prefix  = "regression_fqa_norway/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_portugal"
      enabled = true
      prefix  = "regression_fqa_portugal/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_ru"
      enabled = true
      prefix  = "regression_fqa_ru/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_spain"
      enabled = true
      prefix  = "regression_fqa_spain/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_sweden"
      enabled = true
      prefix  = "regression_fqa_sweden/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "regression_fqa_switzerland"
      enabled = true
      prefix  = "regression_fqa_switzerland/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "run_by_maven_cmd"
      enabled = true
      prefix  = "run_by_maven_cmd/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "rm_eu_prod_autotests_monitoring"
      enabled = true
      prefix  = "rm_-_eu_prod_autotests_monitoring/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "rm_prod_autotests_monitoring_eu"
      enabled = true
      prefix  = "rm_-_prod_autotests_monitoring_eu/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "scheduled_pos"
      enabled = true
      prefix  = "scheduled_pos/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "scheduled_pos_tests_ru"
      enabled = true
      prefix  = "scheduled_pos_tests_ru/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "uat_eu_scheduled_smoke_tests"
      enabled = true
      prefix  = "uat_eu_scheduled_smoke_tests/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "dev_eu_scheduled_smoke_tests"
      enabled = true
      prefix  = "dev_eu_scheduled_smoke_tests/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "fqa_eu_scheduled_smoke_tests"
      enabled = true
      prefix  = "fqa_eu_scheduled_smoke_tests/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "fqa_ru_scheduled_smoke_tests"
      enabled = true
      prefix  = "fqa_ru_scheduled_smoke_tests/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "order_generator_on_fqa_eu"
      enabled = true
      prefix  = "order_generator_on_fqa_eu/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "order_generator_on_uat_eu"
      enabled = true
      prefix  = "order_generator_on_uat_eu/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "scheduled_smoke_tests_eu_on_dev"
      enabled = true
      prefix  = "scheduled_smoke_tests_eu_on_dev/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "scheduled_smoke_tests_eu_on_fqa"
      enabled = true
      prefix  = "scheduled_smoke_tests_eu_on_fqa/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "scheduled_smoke_tests_eu_on_uat"
      enabled = true
      prefix  = "scheduled_smoke_tests_eu_on_uat/"

      expiration = {
        days = 30
      }
    },
    {
      id      = "scheduled_smoke_tests_ru_on_fqa"
      enabled = true
      prefix  = "scheduled_smoke_tests_ru_on_fqa/"

      expiration = {
        days = 30
      }
    },
  ]
}
