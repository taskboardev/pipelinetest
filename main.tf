provider "aws" {
  profile = "taskboar"
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name                 = "main"
  cidr                 = "10.0.0.0/16"

  azs                  = ["us-east-1a" , "us-east-1b" ]
  public_subnets       = ["10.0.1.0/24"]
  private_subnets      = ["10.0.101.0/24" , "10.0.102.0/24"]
}

module "nat" {
  source = "int128/nat-instance/aws"

  name                        = "main"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
}

resource "aws_iam_role" "example" {
  name = "example"
  assume_role_policy = file("files/assume-role-policy.json")
}

resource "aws_iam_role_policy" "example" {
  role = aws_iam_role.example.name
  policy = file("files/iam-role-policy.json")
}

resource "aws_codebuild_project" "example" {
  name          = "test-project"
  description   = "test_codebuild_project"
  service_role  = aws_iam_role.example.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "LOCAL"
    modes    = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

//    environment_variable {
//      name  = "SOME_KEY2"
//      value = "SOME_VALUE2"
//      type  = "PARAMETER_STORE"
//    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  source_version = "master"
  source {
    type            = "GITHUB"
    location        = "git@github.com:taskboardev/pipelinetest.git"
  }

  vpc_config {
    vpc_id = module.vpc.vpc_id
    subnets = [module.vpc.private_subnets]
    security_group_ids = [module.vpc.default_security_group_id]
  }
}

