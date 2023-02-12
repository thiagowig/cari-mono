######### Database

resource "aws_security_group" "allow_access_cori_db" {
  name = "allow_access_cori_db"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.ALLOWED_IPS
  }
}

resource "aws_db_instance" "cori_db_instance" {
  identifier             = "coridb"
  instance_class         = "db.t4g.micro"
  allocated_storage      = 8
  db_name                = "coridb"
  engine                 = "postgres"
  engine_version         = "14.6"
  username               = var.CORI_DATABASE_USER
  password               = var.CORI_DATABASE_PASSWORD
  vpc_security_group_ids = [aws_security_group.allow_access_cori_db.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
}


######### Queues
resource "aws_sqs_queue" "sqs_test" {
  name                      = "sqs_test"
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue" "sqs_test_dlq" {
  name = "sqs_test_dlq"
}

resource "aws_sqs_queue_redrive_policy" "sqs_test_redrive_policy" {
  queue_url = aws_sqs_queue.sqs_test.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_test_dlq.arn
    maxReceiveCount     = 4
  })

  depends_on = [
    aws_sqs_queue.sqs_test,
    aws_sqs_queue.sqs_test_dlq
  ]
}

resource "aws_sqs_queue_redrive_allow_policy" "sqs_test_dlq_redrive_allow_policy" {
  queue_url = aws_sqs_queue.sqs_test_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.sqs_test.arn]
  })

  depends_on = [
    aws_sqs_queue.sqs_test,
    aws_sqs_queue.sqs_test_dlq
  ]
}


######### Notifications

resource "aws_sns_topic" "sns_test" {
  name = "sns_test"
}

resource "aws_sns_topic_subscription" "sns_test_subscription" {
  topic_arn = aws_sns_topic.sns_test.arn
  protocol  = "email"
  endpoint  = var.CORI_ALARM_USER
}


######### Alarm

resource "aws_cloudwatch_metric_alarm" "dlq_new_message_alarm" {
  alarm_name          = "dlq_new_message_alarm"
  statistic           = "Sum"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  period              = 60
  evaluation_periods  = 2
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  dimensions = {
    QueueName = aws_sqs_queue.sqs_test_dlq.name
  }
  alarm_actions = [aws_sns_topic.sns_test.arn]
  ok_actions    = [aws_sns_topic.sns_test.arn]
}

