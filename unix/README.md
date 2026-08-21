# Unix Setup Scripts

Modular, easy-to-use scripts for setting up a development environment on
**Linux** and **macOS**.

| Platform | Package manager |
|----------|-----------------|
| Debian / Ubuntu | `apt` |
| Arch | `pacman` |
| Fedora | `dnf` |
| NixOS | delegated to your flake + home-manager repo |
| macOS | `brew` (Homebrew) |

The scripts target **bash 3.2**, which is what `/bin/bash` still is on macOS, so
avoid bash 4+ syntax (associative arrays, `${var,,}`, `mapfile`) when editing.

## Quick Start

```bash
# Run the full setup (installs everything)
./setup.sh full

# Preview what would be installed (dry-run mode)
./setup.sh full --dry-run

# Install with detailed logging
./setup.sh full --log

# Install only what you need
./setup.sh basic          # Basic packages
./setup.sh languages      # All programming languages
./setup.sh languages python  # Just Python

# Check platform, free space, and what's installed
./setup.sh status
```

On macOS, Homebrew must already be installed. The scripts will tell you how if
it is missing rather than installing it behind your back.

## Reclaiming disk space

`clean` is the most-used command, so it gets its own section.

```bash
./setup.sh clean --dry-run      # show what would go, delete nothing
./setup.sh clean                # clear caches
./setup.sh clean --trash        # ...and empty the trash
./setup.sh clean --containers   # ...and prune dangling docker/podman images
```

Always worth running `--dry-run` first: it prints every target with its size and
a total, without touching anything.

### What it cleans

**Both platforms**

- `~/.cache` (`$XDG_CACHE_HOME`)
- System package manager caches: `apt autoclean`/`autoremove`, `pacman -Scc`,
  `dnf clean all`, or `brew cleanup --prune=all`. Nix-managed systems (NixOS,
  nix-darwin) get `nix-collect-garbage -d` instead of package-manager cleanup.
- Language/tool caches: uv, conda, pip, npm, pnpm, yarn, cargo, go, mise

**macOS only**

- Application caches in `~/Library/Caches`
- Xcode `DerivedData`, iOS/watchOS `DeviceSupport`, CoreSimulator caches, and
  unavailable simulator runtimes
- User logs in `~/Library/Logs` older than 7 days
- Local Time Machine APFS snapshots (thinned, needs sudo)

**Linux only**

- `journalctl --vacuum-time=7d`

### Safety behaviour

- Everything removed by default is **regenerable** — caches get rebuilt on next
  use. Emptying the trash is the one destructive action, so it is opt-in behind
  `--trash`.
- Xcode **Archives are never touched**: those are shipped build artifacts, not
  cache.
- Container cleanup only prunes **dangling images**; your containers and tagged
  images are left alone.
- A cache is **skipped while its app is running** (browsers, Spotify), so a live
  app never has the ground pulled out from under it.
- Every deletion goes through a guard that refuses `/`, `$HOME`, anything
  outside known cache roots, and any path containing `..`.
- Steps needing root are **skipped with a warning** when sudo is unavailable
  instead of failing the whole run.
- Entries under 10MB are counted but not printed individually, so the output
  stays readable. Override with `PURGE_MIN_REPORT_KB=0`.

## Available Commands

```bash
./setup.sh [COMMAND] [OPTIONS]
```

| Command | Description | Platform |
|---------|-------------|----------|
| `full` | Install everything | both |
| `basic` | Install basic packages | both |
| `editor` | Install Neovim | both |
| `terminal` | Install terminal emulators (WezTerm, Alacritty, Kitty) | both |
| `kitty` | Install Kitty terminal emulator | both |
| `shell` | Install Oh My Zsh | both |
| `atuin` | Install atuin shell history | both |
| `zoxide` | Install zoxide directory jumper | both |
| `languages [LANG]` | Install programming languages | both |
| `libraries [LIB]` | Install development libraries | both |
| `conda` | Install miniconda | both |
| `mise` | Install mise-en-place | both |
| `docker` | Install Docker | both |
| `upgrade` | Upgrade all system packages | both |
| `clean` | Clean disk space | both |
| `network` | Update DNS to 8.8.8.8 / 1.1.1.1 | both |
| `status` | Show platform and installed components | both |
| `i3status` | Install i3status | Linux |
| `raylib` | Install Raylib | Linux |
| `cuda` | Install CUDA toolkit | Linux |
| `help` | Show help | both |

Linux-only commands exit **successfully** with an explanatory note on macOS, so
`setup.sh full` never aborts partway through on a Mac.

### Global options

| Option | Effect |
|--------|--------|
| `--dry-run` | Print what would happen; change nothing |
| `--log` | Write a detailed log to `~/.unix-setup/logs/` |

State, backups, and logs live in `~/.unix-setup/`. An existing
`~/.linux-setup/` directory is reused if present, so upgrading from the older
layout keeps your history.

### Platform differences worth knowing

| Component | Linux | macOS |
|-----------|-------|-------|
| Neovim | tarball into `/opt` | `brew install neovim` |
| Terminals | distro packages / upstream installer | Homebrew casks |
| Docker | Docker CE from Docker's apt repo | Colima + docker CLI (`--desktop` for Docker Desktop) |
| Java | `default-jdk` | keg-only `openjdk` (symlink hint printed) |
| X11 libraries | `libx11-dev` etc. | skipped — no native X11 |
| DNS | `systemd-resolved` / `resolv.conf` | `networksetup` + DNS cache flush |
| Clipboard | `wl-clipboard` | built-in `pbcopy`/`pbpaste` |

### Language Options

```bash
./setup.sh languages          # all
./setup.sh languages [python|nodejs|r|java|rust|julia|go|haskell|cpp]
```

### Library Options

```bash
./setup.sh libraries          # all
./setup.sh libraries [x11|math]
```

- `x11`: X11 development libraries (Linux only)
- `math`: OpenBLAS + SuiteSparse

## Individual Script Usage

All scripts in `setup/` and `system/` can be run independently:

```bash
./setup/neovim.sh
./system/clean-disk.sh --dry-run
./setup/languages.sh python
```

## Layout

```
setup.sh              # dispatcher
lib/common.sh         # shared helpers: OS detection, package managers, purge helpers
setup/                # per-component installers
system/               # maintenance: clean-disk, upgrade-packages, update-network
services/             # systemd units (Linux only)
tools/                # misc helper scripts
archive/              # superseded scripts, kept for reference
```

## Development

```bash
# Lint everything (shellcheck follows the sourced lib with -x)
shellcheck -x setup.sh lib/common.sh setup/*.sh system/*.sh

# Confirm bash 3.2 compatibility
for f in setup.sh lib/common.sh setup/*.sh system/*.sh; do /bin/bash -n "$f"; done
```
