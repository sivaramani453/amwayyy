[
  {
    "name": "${name}",
    "cpu": ${cpu},
    "memory": ${memory},
    "image": "${docker_image}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${container_port}
      }
    ],
    "environment" : [
        { "name" : "PORT", "value" : "${container_port}" },
        { "name" : "STORAGE", "value" : "${storage}" },
        { "name" : "STORAGE_AMAZON_BUCKET", "value" : "${storage_amazon_bucket}" },
        { "name" : "STORAGE_AMAZON_REGION", "value" : "${storage_amazon_region}" },
        { "name" : "CHART_URL", "value" : "${chart_url}" }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-region": "${region}",
            "awslogs-group": "${log-group}",
            "awslogs-stream-prefix": "${log-prefix}"
        }
    }
  }
]
