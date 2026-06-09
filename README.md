# Infrastructure

Azure infrastructure managed with [Terramate](https://terramate.io/) + OpenTofu/Terraform.

## Layout

```
.
├── README.md
├── dev
│   └── central-us
│       ├── config.tm.hcl
│       ├── hub
│       │   ├── backend.tf
│       │   ├── compute
│       │   │   ├── README.md
│       │   │   ├── backend.tf
│       │   │   ├── main.tf
│       │   │   └── stack.tm.hcl
│       │   ├── dns
│       │   │   ├── backend.tf
│       │   │   ├── main.tf
│       │   │   └── stack.tm.hcl
│       │   ├── firewall-rules
│       │   │   ├── backend.tf
│       │   │   ├── generated_sharing.tf
│       │   │   ├── main.tf
│       │   │   └── stack.tm.hcl
│       │   ├── main.tf
│       │   ├── private-link
│       │   │   ├── backend.tf
│       │   │   ├── main.tf
│       │   │   └── stack.tm.hcl
│       │   ├── stack.tm.hcl
│       │   └── vwan-config
│       │       ├── backend.tf
│       │       ├── main.tf
│       │       └── stack.tm.hcl
│       └── spokes
│           ├── connect
│           │   ├── compute
│           │   │   ├── backend.tf
│           │   │   ├── main.tf
│           │   │   └── stack.tm.hcl
│           │   ├── databases
│           │   │   ├── backend.tf
│           │   │   ├── main.tf
│           │   │   └── stack.tm.hcl
│           │   ├── main.tf
│           │   └── stack.tm.hcl
│           └── integrations
│               ├── compute
│               │   ├── backend.tf
│               │   ├── main.tf
│               │   └── stack.tm.hcl
│               ├── main.tf
│               └── stack.tm.hcl
└── terramate.tm.hcl
```

A directory is a stack if its `stack.tm.hcl` contains a `stack {}` block. Intermediate dirs (`hub/`, `spokes/connect/`, etc.) group stacks but aren't themselves stacks.

## State backend

State lives in S3, one key per stack. The backend block is **generated**, not hand-written — never commit a `backend.tf` by hand.

### How generation works

`dev/central-us/config.tm.hcl` declares:

- `globals` — `backend_bucket`, `backend_region`, `backend_dynamodb_table`.
- A `generate_hcl "backend.tf"` block that emits `terraform { backend "s3" { ... } }`.

Terramate cascades both down to every descendant stack. Running `terramate generate` writes a `backend.tf` next to each stack's `main.tf`, with a per-stack key derived from `terramate.stack.path.absolute`, e.g.:

```
/dev/central-us/hub/dns/terraform.tfstate
/dev/central-us/spokes/connect/databases/terraform.tfstate
```

### Why env-scoped and not repo-root

Different environments often want their own bucket for blast-radius isolation. Defining backend globals at the env level (`dev/central-us/`) means a future `prod/` can override bucket/region without inheriting dev's. If you add a new env, copy `config.tm.hcl` into it and adjust the globals.

### Sharing outputs between stacks

Cross-stack outputs use Terramate's [outputs sharing](https://terramate.io/docs/cli/orchestration/outputs-sharing), configured once in the repo-root `terramate.tm.hcl` via a `sharing_backend "shared_outputs"` block. Stacks declare `output {}` / `input {}` blocks; Terramate generates `generated_sharing.tf` to wire them up.

## Workflow

```sh
terramate generate # write backend.tf + sharing files into stacks
terramate run --parallel 1 --changed -- tofu init
terramate run --parallel 5 --changed -- tofu plan -out out.tfplan
terramate run --parallel 5 --changed -- tofu apply -input=false -auto-approve -lock-timeout=5m out.tfplan # respects after = [...] ordering
```

Scope a run to one stack with `terramate run --chdir dev/central-us/hub/dns -- tofu plan`.

## Adding a new stack

```sh
terramate create dev/central-us/<path>/<name>
terramate generate
```

`create` writes `stack.tm.hcl` with a fresh UUID; `generate` picks up the cascading backend block and emits `backend.tf`. Add a `main.tf` and you're done.

## First-time setup

Before the first `terramate generate`, fill in the `REPLACE_ME` placeholders in `dev/central-us/config.tm.hcl`:

- `backend_bucket` — the S3 bucket holding tfstate
- `backend_dynamodb_table` — the DynamoDB table used for state locking

`backend_region` is already set to `centralus` — adjust if your state bucket lives elsewhere.
