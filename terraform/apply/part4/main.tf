terraform {
  backend "s3" {
    bucket         = "bogaczio-terraform"
    region         = "us-east-2"
    dynamodb_table = "bogaczio-state-file-lock"
    key            = "state/sandbox/go18talk-fourth"
  }
}

locals {
  talk_phase    = "go18talk-fourth"
  function_name = "toy"
  filepath      = "${format("%s/../../../fourth/%s.zip", path.module, local.function_name)}"
}

module "api" {
  source          = "../../modules/api"
  api_name        = "${local.talk_phase}"
  api_description = "fourth implementation of our API"
  environment     = "sandbox"

  # S3 Config
  bucket_name       = "${format("%s-bucket", local.talk_phase)}"
  enable_expiration = true

  # Lambda Config
  lambda_function_name     = "${local.function_name}"
  lambda_executable_name   = "${local.function_name}"
  lambda_function_filepath = "${local.filepath}"
  lambda_timeout           = 5

  tags = {
    Type  = "Demo projects"
    Event = "Gophercon 2018 Kickoff Party"
  }
}

output "api_url" {
  value = "${module.api.api_url}"
}
