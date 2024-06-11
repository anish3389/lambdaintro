module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "anish-lambda-bucket2"
}

module "lambda_layer_s3" {
  source = "terraform-aws-modules/lambda/aws"

  create_layer = true

  layer_name          = "thubmnail_layer_lambda_anish"
  compatible_runtimes = ["python3.10"]

  source_path = [
    {
      path             = "../dependencies"
      pip_requirements = true
      prefix_in_zip    = "python"
    }
  ]

  runtime = "python3.10"

  store_on_s3 = true
  s3_bucket   = module.s3_bucket.s3_bucket_id
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "thumb_anish"
  handler = "main.lambda_handler"
  runtime = "python3.10"
  timeout = 10

  layers = [
    module.lambda_layer_s3.lambda_layer_arn
  ]

  source_path              = "../src/main.py"
  attach_policy_statements = true
  policy_statements = {
    s3_read = {
      effect = "Allow",
      actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      resources = ["arn:aws:s3:::anish-lambda-bucket2/*"]
    }
  }
}


module "s3_bucket_notification" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version = "4.1.2"

  bucket     = module.s3_bucket.s3_bucket_id
  bucket_arn = module.s3_bucket.s3_bucket_arn
  lambda_notifications = {
    trigger1 = {
      function_arn        = module.lambda_function.lambda_function_arn
      function_name       = module.lambda_function.lambda_function_name
      lambda_function_arn = module.lambda_function.lambda_function_qualified_arn
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = "uploads/"
      filter_suffix       = ".jpg"
    }
  }
}
