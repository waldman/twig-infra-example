# twig-infra-example

Reference implementation for [twig](https://github.com/waldman/twig) — a thin Terraform runner that uses path-as-data YAML leaves instead of HCL boilerplate.

This repo provides:
- **7 reusable AWS Terraform modules** (`modules/aws/5/`)
- **4 example leaves** that exercise all modules, including cross-leaf `remote_state` references

Use it as a starter template, or reference the modules from any twig project via git URL.

## Prerequisites

- [twig](https://github.com/waldman/twig/releases) in `$PATH`
- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.1` in `$PATH`
- AWS credentials configured with a named profile in `~/.aws/credentials`

## Quick start

### 1. Bootstrap state infrastructure (one-time)

twig uses an S3 backend. Create the bucket and optional DynamoDB lock table before running any leaves:

```bash
PROFILE=myprofile
BUCKET=my-terraform-state
REGION=us-east-1
TABLE=my-terraform-locks

aws --profile $PROFILE s3api create-bucket \
    --bucket $BUCKET --region $REGION

aws --profile $PROFILE s3api put-bucket-versioning \
    --bucket $BUCKET \
    --versioning-configuration Status=Enabled

aws --profile $PROFILE s3api put-bucket-encryption \
    --bucket $BUCKET \
    --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws --profile $PROFILE s3api put-public-access-block \
    --bucket $BUCKET \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

aws --profile $PROFILE dynamodb create-table \
    --table-name $TABLE \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $REGION
```

### 2. Configure this repo

Edit `twig.yaml` to match your setup:

```yaml
modules_path: ./modules

backend:
  bucket:         my-terraform-state   # your state bucket
  region:         us-east-1
  dynamodb_table: my-terraform-locks   # optional
  profile:        myprofile            # your AWS profile
```

Rename `infra/aws/myprofile/` to match your AWS profile name.

### 3. Run an example

```bash
# Replace the placeholder SSH key first:
$EDITOR infra/aws/myprofile/us-east-1/base/ec2/default-key-pair.yaml

twig plan  infra/aws/myprofile/us-east-1/base/vpc/main.yaml
twig apply infra/aws/myprofile/us-east-1/base/vpc/main.yaml

twig plan  infra/aws/myprofile/us-east-1/base/ec2/default-key-pair.yaml
twig apply infra/aws/myprofile/us-east-1/base/ec2/default-key-pair.yaml

twig plan  infra/aws/myprofile/us-east-1/dev/ec2/test-ec2.yaml
twig apply infra/aws/myprofile/us-east-1/dev/ec2/test-ec2.yaml
```

## Directory layout

```
twig-infra-example/
├── twig.yaml                              # backend config + modules path
├── modules/
│   └── aws/
│       └── 5/                            # AWS provider major version
│           ├── vpc/
│           ├── security-group/
│           ├── ec2/
│           ├── ec2-key-pair/
│           ├── s3-bucket/
│           ├── dynamodb/
│           ├── iam-user/
│           └── iam-policy/
└── infra/
    └── aws/
        └── myprofile/
            └── us-east-1/
                ├── base/
                │   ├── vpc/main.yaml              # VPC + subnets + NAT
                │   └── ec2/default-key-pair.yaml  # SSH key pair
                └── dev/
                    ├── ec2/test-ec2.yaml           # EC2 instance (cross-leaf refs)
                    └── services/my-app.yaml        # S3 + DynamoDB + IAM users/policies
```

## Using these modules from another project

Reference this repo's modules from any twig project via git URL:

```yaml
# twig.yaml in your project
modules_path: github.com/waldman/twig-infra-example//modules
modules_ref:  v1.0.0
```

twig generates the correct `git::` Terraform source URL; `terraform init` fetches the modules automatically.

## Modules

All modules receive 7 path-derived variables automatically from twig:

| Variable      | Source                  |
|---------------|-------------------------|
| `cloud`       | path segment            |
| `profile`     | path segment            |
| `region`      | path segment            |
| `environment` | path segment            |
| `class`       | path segment            |
| `component`   | filename (no `.yaml`)   |
| `module`      | instance key in YAML    |

Module-specific variables are prefixed with the module name (e.g. `vpc_cidr_block`, `ec2_ami`, `s3_bucket_name`).

| Module           | Creates                                              |
|------------------|------------------------------------------------------|
| `vpc`            | VPC, public/private subnets, NAT gateway, route tables |
| `security-group` | Security group with configurable ingress rules       |
| `ec2`            | EC2 instance (takes `ec2_security_group_ids`)        |
| `ec2-key-pair`   | AWS key pair from a public key                       |
| `s3-bucket`      | S3 bucket with versioning and encryption             |
| `dynamodb`       | DynamoDB table (PAY_PER_REQUEST by default)          |
| `iam-user`       | IAM user, optional access key → Secrets Manager      |
| `iam-policy`     | IAM policy document + user attachment                |

## License

MIT — see [LICENSE](LICENSE).
