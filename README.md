# S3

Automation for creation of S3 bucket

## TL;DR

Peharps the simplest way to create bucket is to 

1. Add a definition like below to `workspaces/<env>/<aws_region>/resources/main.yaml`
```
myfirstbucket.[my-domain]: {}
```
For more complex way of creating/defining S3 bucket, refer to `auto.tf`
```
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "<version number>"
```
2. Bucket policy is created by droping a json file with bucket-name in the `resources/policies` folder.

## How to use
1. Fill in the Domain field in `setup.config`.

2. Select the Tier, for s3, it needs tier 2 or Tier 3. See Tiers for details. Fill your domain.

3. Create a bucket, See **Creating S3 bucket to manage states.**

4. Run the following to setup your workspace, this will create all the related files
```
make scaffold env=<env> region=<region>
```
**e.g.**
```
make scaffold env=demo region=ap-southeast-1
```

5. Define ur bucket, see TLDR.

6. Enter terraform shell
```
make shell env=<env> region=<region>

# terraform init 
# terraform plan
...
```

## Creating S3 bucket to manage states.

By default, a bucket with the following convention `${env}.terraform.${domain}` is define in `base/provider.tf.gotmpl` and defaults the bucket region to `ap-southeast-1`. Change the region if you need to and create a bucket. .


## Tiers
Tier 1: `env` represents AWS account/profile, in you `~/.aws/config`
Tier 2: On top of `env`, `region` is required. represent `aws_region`, e.g. `ap-southeast-1`
Tier 3: `group` is a separator for example `env` can be AWS account where `group` is production, staging & etc or logical groups
