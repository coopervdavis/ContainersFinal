resource "aws_ecs_cluster" "main" {
  name = "nhl-cluster"
}

resource "aws_security_group" "ecs_tasks_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# New CloudWatch Log Group for your Django container
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/nhl-app"
  retention_in_days = 7
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
      { name = "AWS_STORAGE_BUCKET_NAME", value = aws_s3_bucket.media.bucket },
      { name = "AWS_S3_CUSTOM_DOMAIN", value = aws_cloudfront_distribution.cdn.domain_name }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
        "awslogs-region"        = "us-east-2"
        "awslogs-stream-prefix" = "ecs"
      }
    }
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