terraform {
  backend "s3" {
    bucket         = "bogaczio-terraform"
    region         = "us-east-2"
    dynamodb_table = "bogaczio-state-file-lock"
    key            = "state/sandbox/go18talk-phase1"
  }
}

locals {
  talk_phase    = "go18talk-phase1"
  function_name = "toy"
  filepath      = "${format("%s/../../../first/%s.zip", path.module, local.function_name)}"
}

module "api" {
  source          = "../../modules/api"
  api_name        = "${local.talk_phase}"
  api_description = "first POC implementation of our API"
  environment     = "sandbox"

  # S3 Config
  bucket_name       = "${format("%s-bucket", local.talk_phase)}"
  enable_expiration = true

  # Lambda Config
  lambda_function_name     = "${local.function_name}"
  lambda_executable_name   = "${local.function_name}"
  lambda_function_filepath = "${local.filepath}"
  lambda_timeout           = 5

  lambda_env_vars = {
    SALT = "tVfTXzAfsTtS87PXFzALb64sKzTWm1dNMggdAZdWonE="
  }

  tags = {
    Type  = "Demo projects"
    Event = "Gophercon 2018 Kickoff Party"
  }
}

output "api_url" {
  value = "${module.api.api_url}"
}
