# cloud

Dev VMs on demand. Terraform launches the VM; `ansible/cloud.yml` provisions it with the same roles as every other host (`site.yml`), then adds Docker Sandboxes and pushes the credentials listed in `creds.yml`.

```sh
cloud up dev                                   # create + provision
cloud up big -var instance_type=m8i.2xlarge -var disk_gb=200
ssh dev
cloud stop dev                                 # keeps the disk
cloud start dev                                # also re-locks ssh to your current IP
cloud creds dev                                # push creds.yml again
cloud provision dev -t sandbox                 # rerun selected ansible roles
cloud tf dev plan                              # raw terraform with the vm's vars
cloud ls
cloud down dev                                 # destroy; removes github key, ssh alias, local state
```

## One-time setup

- Terraform comes from `PATH`, else the flake here (`nix develop ./cloud`). nixpkgs marks terraform unfree, so the first build compiles it.
- `gh auth refresh -h github.com -s admin:ssh_signing_key` lets `cloud up` register the VM key for commit signing too; without it commits from the VM show as Unverified.
- `~/.config/cloud/aws.tfvars` holds private defaults, e.g. `s3_buckets = ["my-bucket"]`.
- `TS_AUTHKEY` in your env joins the VM to your tailnet (use a reusable, non-ephemeral key).
- `~/.ssh/config` must start with `Include ~/.ssh/cloud/*.conf` (chezmoi adds it).

## First login on a VM

Docker Sandboxes needs a Docker sign-in and a network policy before it creates sandboxes:

```sh
sbx login                     # or set DOCKERHUB_USER + DOCKERHUB_TOKEN before `cloud creds`
sbx policy init balanced      # allow-all | balanced | deny-all
```

There is no keyring session on the VM, so `sbx secret` stores secrets in a 0600 file under `~/.local/state/sandboxes`.

## Settings

Later wins:

1. `providers/<p>/variables.tf`: defaults
2. `~/.config/cloud/<p>.tfvars`: private defaults, read on every command, so edits reach existing VMs at their next `up`/`start`
3. `-var` / `-var-file` on `up`, `start`, `stop`: per VM, saved in `~/.local/state/cloud/<vm>/vars`

`cloud` sets `name`, `ssh_pubkey` (`CLOUD_SSH_KEY`, default `~/.ssh/id_ed25519`), `ssh_cidrs` (your public IP) and `running`. Any plan that deletes or replaces a resource asks first; `-y` skips the prompt.

## What a VM gets (aws defaults)

- Ubuntu 26.04 on `m8i-flex.xlarge` (4 vCPU, 16 GB), 100 GB encrypted gp3, nested virtualization on, so `/dev/kvm` exists for `sbx`
- everything in `site.yml`: chezmoi dotfiles, zsh, mise tools, Claude Code, skill vault and harness configs
- docker.io with buildx and compose, docker-sbx, tailscale
- an instance role with read/write on `s3_buckets`, used by aws cli, rclone and boto3 with no keys on disk. IMDSv2 with hop limit 1 keeps the role away from docker containers; `-var imds_hop_limit=2` opens it to them
- ssh and mosh reachable only from the IP that ran the last `up`/`start`
- GitHub key `cloud-<vm>` for auth and signing, deleted by `down`

## Credentials

`creds.yml` lists sources, never values: `{env: VAR}` or `{cmd: "..."}`, resolved on your machine at push time. Empty results are skipped.

- `cloud_env`: exported in every shell on the VM via `~/.config/cloud/env` (0600), sourced from `~/.zshenv` and `~/.bashrc`. The file is rewritten on each push, so a removed line disappears from the VM.
- `cloud_secrets`: setup only (`tailscale up`, `sbx login`), never written to disk.
- `cloud_files`: copied as-is with mode 0600. Removing an entry does not delete the file from the VM.

A private manifest at `~/.config/cloud/creds.yml` (or `CLOUD_CREDS=<file>`) replaces the tracked one.

## Adding a provider

Create `providers/<name>/` as a Terraform root module that:

- takes `name`, `ssh_pubkey`, `ssh_cidrs`, `running`, plus its own variables
- outputs `host` (empty while stopped), `user`, `id`, `state`
- declares `backend "local" {}`; `cloud` points it at the VM's state file
- builds user data with `modules/cloud-init`

Then `cloud up <vm> -p <name>`. The CLI and Ansible need no changes.

## State

Each VM's Terraform state lives in `~/.local/state/cloud/<vm>/`, on this machine only. If it is lost, find the leftovers with:

```sh
aws ec2 describe-instances --filters Name=tag:ManagedBy,Values=cloud --query 'Reservations[].Instances[].[Tags[?Key==`CloudVM`]|[0].Value,InstanceId,State.Name]'
```
