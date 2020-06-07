vpc
public subnet
    nat instance

private subnet
    codebuild
        access github with gh credentials via nat instance

cloudwatch group for codebuild



links
---
https://github.com/cloudposse/terraform-aws-codebuild
https://github.com/cloudposse/terraform-aws-cloudwatch-logs/blob/0.3.0/main.tf
https://www.youtube.com/watch?v=3CcGtRidF9c
https://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html
