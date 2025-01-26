output "target_group_arns" {
  value = [
    module.nlb-strikh-qa-kz.aws_lb_target_group_arn,
    module.nlb-strikh-qa-ru.aws_lb_target_group_arn,
    module.nlb-mdms-perf-ru.aws_lb_target_group_arn,
    module.nlb-mdms-qa-ru.aws_lb_target_group_arn,
    module.nlb-mdms-qa-kz.aws_lb_target_group_arn,
    aws_lb_target_group.prerender_tg.arn
  ]
}

