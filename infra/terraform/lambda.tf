########## Lambda
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"

  depends_on = [
    aws_iam_role.iam_for_lambda
  ]
}

data "archive_file" "lambda_file" {
  type        = "zip"
  source_file = "app/lambda.js"
  output_path = "app/lambda.zip"
}

resource "aws_lambda_function" "test_lambda" {
  function_name                  = "test_lambda"
  role                           = aws_iam_role.iam_for_lambda.arn
  filename                       = "app/lambda.zip"
  runtime                        = "nodejs16.x"
  handler                        = "index.handler"
  timeout                        = 10

  depends_on = [
    aws_iam_role.iam_for_lambda
  ]
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  function_name                      = aws_lambda_function.test_lambda.arn
  event_source_arn                   = aws_sqs_queue.sqs_test.arn
  enabled                            = true
  batch_size                         = 2
  maximum_batching_window_in_seconds = 5

  depends_on = [
    aws_sqs_queue.sqs_test,
    aws_lambda_function.test_lambda
  ]
}