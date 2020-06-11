variable "region" {
  default = "us-east-1"
}
variable "profile" {
  default = "taskboar"
}
variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}

provider "aws" {
  profile = var.profile
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name                 = "main"
  cidr                 = "10.0.0.0/16"

  azs                  = var.availability_zones
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

//resource "aws_iam_role" "ci" {
//  name = "ci"
//  assume_role_policy = file("files/ci-assume-role-policy.json")
//}
//
//resource "aws_iam_role_policy" "ci" {
//  role = aws_iam_role.ci.name
//  policy = file("files/ci-iam-role-policy.json")
//}

resource "aws_iam_user" "app" {
  name = "app"
}

resource "aws_iam_user_policy" "dyn" {
  name = "DynamoReadWriteItems"
  user = aws_iam_user.app.name
  policy = file("files/dyn-iam-policy.json")
}

// todo
// https://docs.aws.amazon.com/general/latest/gr/aws-access-keys-best-practices.html
resource "aws_iam_access_key" "app" {
  user = aws_iam_user.app.name
}

resource "aws_dynamodb_table" "main" {
//  provider = "aws.${var.region}"

  hash_key         = "id"
  name             = "dummy"
  read_capacity    = 1
  write_capacity   = 1

  attribute {
    name = "id"
    type = "S"
  }
}

//resource "aws_codebuild_project" "main" {
//  name          = "main"
//  service_role  = aws_iam_role.ci.arn
//
//  artifacts {
//    type = "NO_ARTIFACTS"
//  }
//
//  cache {
//    type     = "LOCAL"
//    modes    = ["LOCAL_DOCKER_LAYER_CACHE"]
//  }
//
//  environment {
//    compute_type                = "BUILD_GENERAL1_SMALL"
//    image                       = "aws/codebuild/standard:1.0"
//    type                        = "LINUX_CONTAINER"
//    image_pull_credentials_type = "CODEBUILD"
//
//    environment_variable {
//      name  = "DYNAMO_REGION"
//      value = var.region
//    }
//
//    environment_variable {
//      name = "DYNAMO_ENDPOINT"
//      value = "http://dynamodb.${var.region}.amazonaws.com"
//    }
//
//    environment_variable {
//      name = "DYNAMO_ACCESS_KEY_ID"
//      value = aws_iam_access_key.app.id
//    }
//
//    environment_variable {
//      name = "DYNAMO_SECRET_ACCESS_KEY_ID"
//      value = aws_iam_access_key.app.secret
//    }
//  }
//
//  logs_config {
//    cloudwatch_logs {
//      group_name  = "log-group"
//      stream_name = "log-stream"
//    }
//  }
//
//  source_version = "master"
//  source {
//    type            = "GITHUB"
//    location        = "git@github.com:taskboardev/pipelinetest.git"
//  }
//
//  vpc_config {
//    vpc_id = module.vpc.vpc_id
//    subnets = module.vpc.private_subnets
//    security_group_ids = [module.vpc.default_security_group_id]
//  }
//}
