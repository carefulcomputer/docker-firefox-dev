# Firefox ESR Development Container

[![Docker Pulls](https://img.shields.io/docker/pulls/carefulcomputer/firefox-esr.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/carefulcomputer/firefox-esr)

Firefox ESR in a Docker container with **unsigned extension support** enabled. Accessible via browser using KasmVNC. Built for extension development and testing.

## Features

- **Firefox ESR** — Extended Support Release, stable and long-lived
- **Unsigned extensions** — pre-configured to allow installing extensions that haven't been signed by Mozilla
- **Experimental extension APIs** — enabled for advanced extension development
- **Multi-platform** — AMD64 and ARM64
- **Web-based** — access via browser on port 3000 (HTTP) or 3001 (HTTPS)
- **Auto-updates** — rebuilds automatically when a new Firefox ESR version is released

## Quick Start

### docker-compose

```yaml
services:
  firefox-esr:
    image: firefox-esr:latest
    container_name: firefox-esr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /path/to/config:/config
    ports:
      - 3000:3000
      - 3001:3001
    shm_size: "1gb"
    security_opt:
      - seccomp:unconfined
    restart: unless-stopped
```

### docker cli

```bash
docker run -d \
  --name=firefox-esr \
  --security-opt seccomp=unconfined \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /path/to/config:/config \
  --shm-size="1gb" \
  --restart unless-stopped \
  firefox-esr:latest
```

Open `http://yourhost:3000` in your browser.

> **Note:** `--shm-size=1gb` is required for modern websites (YouTube, etc.) to work correctly.

> **Note:** `seccomp=unconfined` may be needed on older hosts for GUI apps to function.

## Parameters

| Parameter | Function |
|-----------|----------|
| `-p 3000` | Firefox desktop GUI (HTTP) |
| `-p 3001` | Firefox desktop GUI (HTTPS) |
| `-e PUID` | User ID for file permissions |
| `-e PGID` | Group ID for file permissions |
| `-e TZ` | Timezone, e.g. `America/New_York` |
| `-e FIREFOX_CLI` | Optional CLI flags passed to Firefox on launch |
| `-v /config` | Persistent storage for Firefox profile and settings |

## Extension Support

This image ships with the following Firefox preferences pre-configured:

| Preference | Value | Effect |
|-----------|-------|--------|
| `xpinstall.signatures.required` | `false` | Allow unsigned extensions |
| `extensions.langpacks.signatures.required` | `false` | Allow unsigned language packs |
| `extensions.experiments.enabled` | `true` | Enable experimental extension APIs |
| `extensions.webextensions.restrictedDomains` | `""` | Remove WebExtension domain restrictions |
| `devtools.chrome.enabled` | `true` | Enable browser toolbox |
| `devtools.debugger.remote-enabled` | `true` | Enable remote debugging |
| `extensions.webextensions.keepStorageOnUninstall` | `true` | Preserve storage when uninstalling |
| `extensions.webextensions.keepUuidOnUninstall` | `true` | Preserve UUID when uninstalling |

### Installing an unsigned extension

1. **Drag and drop** — drag a `.xpi` file into the Firefox window
2. **From file** — `about:addons` → gear icon → *Install Add-on From File*
3. **Temporary load** — `about:debugging` → *Load Temporary Add-on*

> **Security:** Unsigned extensions bypass Mozilla's review process. Only install extensions from sources you trust. Do not expose this container to the internet without authentication.

## Automated Updates

A GitHub Actions workflow runs daily and checks the [Mozilla Team PPA](https://launchpad.net/~mozillateam/+archive/ubuntu/ppa) for the latest `firefox-esr` package version.

It compares the PPA version against `.firefox-esr-version` in this repo (which records the last built version). If they differ, the workflow builds and pushes a new multi-platform image to Docker Hub tagged as both `latest` and the specific version (e.g. `140.10.0`), then commits the new version back to `.firefox-esr-version`.

To trigger a manual rebuild: **Actions** → **Check Firefox ESR and Build** → **Run workflow**.

## Building Locally

```bash
git clone https://github.com/carefulcomputer/docker-firefox-dev.git
cd docker-firefox-dev
docker build --no-cache --pull -t firefox-esr:latest .
```

For ARM64 on x86 hardware:

```bash
docker run --rm --privileged lscr.io/linuxserver/qemu-static --reset
docker build --no-cache --pull -f Dockerfile.aarch64 -t firefox-esr:arm64 .
```

## User / Group Identifiers

When using volumes, set `PUID` and `PGID` to match the owner of the host directory to avoid permission issues:

```bash
id your_user
# uid=1000(your_user) gid=1000(your_user)
```

## Credits

Based on [linuxserver/docker-firefox](https://github.com/linuxserver/docker-firefox) and the [linuxserver/docker-baseimage-kasmvnc](https://github.com/linuxserver/docker-baseimage-kasmvnc) infrastructure.

## Versions

- **26.04.25:** — Clean up inherited linuxserver workflows and files. Add automated Firefox ESR version tracking.
- **01.01.25:** — Switch to Firefox ESR. Add unsigned extension support. Multi-platform builds.
- **25.09.24:** — Rebase to Ubuntu Noble.
