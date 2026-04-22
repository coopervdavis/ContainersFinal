resource "aws_ecs_cluster" "main" {
  name = "nhl-cluster"
}

resource "aws_security_group" "ecs_tasks_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Limit to ALB SG in a stricter setup
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "django_app" {
  family                   = "nhl-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "nhl-container"
    image     = "${aws_ecr_repository.app.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 8000
      hostPort      = 8000
    }]
    environment = [
      { name = "DATABASE_URL", value = "postgres://dbadmin:SuperSecretPassword123!@${aws_db_instance.postgres.endpoint}/nhldb" },
      # Add AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY for S3 uploads if not using task roles
    ]
  }])
}

resource "aws_ecs_service" "main" {
  name            = "nhl-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.django_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }
}

resource "aws_ecr_repository" "app" {
  name = "nhl-django-app"
}
