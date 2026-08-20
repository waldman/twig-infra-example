# twig-infra-example

Reference implementation for [twig](https://github.com/waldman/twig) — a thin Terraform runner that uses path-as-data YAML leaves instead of HCL boilerplate.

This repo provides:
- **7 reusable AWS Terraform modules** (`modules/aws/5/`)
- **4 example leaves** that exercise all modules, cross-leaf `remote_state` references, and every `vars.yaml` section (`vars:`, `remote_state:`, `module_defaults:`)

Use it as a starter template, or reference the modules from any twig project via git URL.

## Prerequisites

- [twig](https://github.com/waldman/twig/releases) in `$PATH`
- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.10` in `$PATH`
- AWS credentials configured with a named profile in `~/.aws/credentials`

## Quick start

### 1. Bootstrap state infrastructure (one-time)

The `bootstrap/` directory is a small vanilla Terraform module (no twig, no
backend block) that creates the S3 state bucket:

```bash
cd bootstrap/
terraform init
terraform apply -var="profile=myprofile" -var="bucket_name=my-terraform-state"
```

Outputs give you exactly what to paste into `twig.yaml`. After apply, commit
the state file — it contains no secrets:

```bash
git add bootstrap/terraform.tfstate bootstrap/.gitignore
git commit -m "bootstrap: state backend created"
```

The `bootstrap/` directory is frozen after this. Do not run plan or apply
again unless intentionally recreating the backend.

### 2. Configure this repo

Edit `twig.yaml` to match your setup:

```yaml
modules_path: ./modules

backend:
  bucket:       my-terraform-state   # your state bucket
  region:       us-east-1
  profile:      myprofile            # your AWS profile
  use_lockfile: true
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
├── bootstrap/                             # one-time state backend setup (run once, then frozen)
│   ├── versions.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── .gitignore                         # un-ignores terraform.tfstate
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
    ├── vars.yaml                             # top-level: shared `vars:` (default_tags)
    └── aws/
        ├── vars.yaml                         # AWS-scoped: `remote_state:` + `module_defaults:`
        └── myprofile/
            └── us-east-1/
                ├── base/
                │   ├── vpc/main.yaml              # VPC + subnets + NAT
                │   └── ec2/default-key-pair.yaml  # SSH key pair
                └── dev/
                    ├── ec2/test-ec2.yaml           # EC2 instance — uses every inheritance feature
                    └── services/my-app.yaml        # S3 + DynamoDB + IAM users/policies
```

## Inheritance via `vars.yaml`

Two `vars.yaml` files demonstrate the three sections. Each level of the tree can define any of them; leaves inherit everything above.

### `infra/vars.yaml` — universal

```yaml
vars:
  default_tags:
    managed_by: terraform
```

`default_tags` is referenced by every leaf via `${vars.default_tags}` — one source of truth for the map, explicit opt-in per module (twig does not auto-inject `vars:` values).

### `infra/aws/vars.yaml` — AWS-scoped

```yaml
remote_state:
  vpc: infra/aws/myprofile/us-east-1/base/vpc/main.yaml

module_defaults:
  aws/5/ec2:
    ec2_ami:       "ami-0c7217cdde317cfec"                 # update for your region
    ec2_subnet_id: ${remote.vpc.first_public_subnet_id}
```

- **`remote_state:`** — every AWS leaf below can reference `${remote.vpc.<field>}` without redeclaring the alias. The `data "terraform_remote_state" "vpc"` block is emitted only in leaves that actually reference it (lazy emission — `my-app.yaml` inherits the alias but produces no data block).
- **`module_defaults."aws/5/ec2"`** — every module whose `source: aws/5/ec2` receives these vars automatically. Leaf `vars:` overrides per key. References inside module_defaults values resolve at generate time against the consuming leaf.

See [`test-ec2.yaml`](infra/aws/myprofile/us-east-1/dev/ec2/test-ec2.yaml) — it declares no `remote_state.vpc`, no `ec2_ami`, no `ec2_subnet_id`. All three come from inherited `vars.yaml` files.

Full reference: [twig docs/vars-yaml.md](https://github.com/waldman/twig/blob/master/docs/vars-yaml.md).

## Provenance

Every argument in the generated `main.tf` carries a trailing `# from: <origin>` comment. Run `twig show <leaf>` and you can trace any value to `path`, `leaf: modules.<x>.vars`, or `<path>: module_defaults."<source>"` in one step.

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
