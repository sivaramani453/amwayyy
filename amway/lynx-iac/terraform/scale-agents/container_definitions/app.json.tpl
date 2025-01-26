[
  {
    "name": "${name}",
    "cpu": ${cpu},
    "memory": ${memory},
    "image": "${docker_image}",
    "essential": true,
	"portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ],
    "environment" : [
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
