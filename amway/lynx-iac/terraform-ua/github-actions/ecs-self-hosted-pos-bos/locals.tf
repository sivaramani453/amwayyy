locals {
  services = [
    {
      # AmwayACS/actions
      git_org            = "AmwayACS"
      git_repo           = "pos-eu"
      git_token          = "${var.git_token}"
      runners            = 5
      labels             = ""
      init_image         = "amway/actions-init:0.1"
      runner_image       = "amway/actions-pos-bos:beta2"
      runner_memory_soft = 1024
    },
  ]
}
