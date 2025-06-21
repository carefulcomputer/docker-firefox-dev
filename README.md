# Firefox ESR Development Container

[![GitHub Stars](https://img.shields.io/github/stars/carefulcomputer/docker-firefox-dev.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/carefulcomputer/docker-firefox-dev)
[![GitHub Release](https://img.shields.io/github/release/carefulcomputer/docker-firefox-dev.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&logo=github)](https://github.com/carefulcomputer/docker-firefox-dev/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/carefulcomputer/firefox-esr.svg?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/carefulcomputer/firefox-esr)

[Firefox ESR](https://www.mozilla.org/en-US/firefox/enterprise/) (Extended Support Release) is a version of Firefox designed for organizations that need extended support for mass deployments. This container provides Firefox ESR with **unsigned extension support enabled** for development and testing purposes.

[![firefox](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/firefox-logo.png)](https://www.mozilla.org/en-US/firefox/enterprise/)

## Features

* 🔥 **Firefox ESR** - Extended Support Release with long-term stability
* 🔓 **Unsigned Extensions** - Pre-configured to allow installation of unsigned extensions
* 🏗️ **Multi-Platform** - Supports both AMD64 and ARM64 architectures
* 🚀 **Auto-Build** - GitHub Actions workflow for automated builds
* 🌐 **Web-Based** - Accessible via web browser using KasmVNC

## Supported Architectures

This image utilizes the docker manifest for multi-platform awareness. More information is available from docker [here](https://distribution.github.io/distribution/spec/manifest-v2-2/#manifest-list).

Simply pulling `carefulcomputer/firefox-esr:latest` should retrieve the correct image for your architecture, but you can also pull specific arch images via tags.

The architectures supported by this image are:

| Architecture | Available | Tag |
| :----: | :----: | ---- |
| x86-64 | ✅ | amd64-\<version tag\> |
| arm64 | ✅ | arm64v8-\<version tag\> |
| armhf | ❌ | |

## Application Setup

The application can be accessed at:

* http://yourhost:3000/
* https://yourhost:3001/

**Modern GUI desktop apps have issues with the latest Docker and syscall compatibility, you can use Docker with the `--security-opt seccomp=unconfined` setting to allow these syscalls on hosts with older Kernels or libseccomp**

### Unsigned Extension Support

This image comes pre-configured with the following Firefox preferences to allow unsigned extensions:

* `xpinstall.signatures.required = false` - Allows installation of unsigned extensions
* `extensions.langpacks.signatures.required = false` - Allows unsigned language packs

>[!WARNING]
>**Security Notice**: Allowing unsigned extensions reduces security as these extensions haven't been reviewed by Mozilla. Only install extensions from trusted sources.

### Installing Unsigned Extensions

You can install unsigned extensions by:

1. **Drag and Drop**: Download the `.xpi` file and drag it into Firefox
2. **File Installation**: Go to `about:addons` → Click the gear icon → "Install Add-on From File"
3. **Developer Mode**: Load temporary extensions from `about:debugging`

### Security

>[!WARNING]
>Do not put this on the Internet if you do not know what you are doing.

By default this container has no authentication and the optional environment variables `CUSTOM_USER` and `PASSWORD` to enable basic http auth via the embedded NGINX server should only be used to locally secure the container from unwanted access on a local network. If exposing this to the Internet we recommend putting it behind a reverse proxy, such as [SWAG](https://github.com/linuxserver/docker-swag), and ensuring a secure authentication solution is in place. From the web interface a terminal can be launched and it is configured for passwordless sudo, so anyone with access to it can install and run whatever they want along with probing your local network.

### Options in all KasmVNC based GUI containers

This container is based on [Docker Baseimage KasmVNC](https://github.com/linuxserver/docker-baseimage-kasmvnc) which means there are additional environment variables and run configurations to enable or disable specific functionality.

#### Optional environment variables

| Variable | Description |
| :----: | --- |
| CUSTOM_PORT | Internal port the container listens on for http if it needs to be swapped from the default 3000. |
| CUSTOM_HTTPS_PORT | Internal port the container listens on for https if it needs to be swapped from the default 3001. |
| CUSTOM_USER | HTTP Basic auth username, abc is default. |
| PASSWORD | HTTP Basic auth password, abc is default. If unset there will be no auth |
| SUBFOLDER | Subfolder for the application if running a subfolder reverse proxy, need both slashes IE `/subfolder/` |
| TITLE | The page title displayed on the web browser, default "KasmVNC Client". |
| FM_HOME | This is the home directory (landing) for the file manager, default "/config". |
| START_DOCKER | If set to false a container with privilege will not automatically start the DinD Docker setup. |
| DRINODE | If mounting in /dev/dri for [DRI3 GPU Acceleration](https://www.kasmweb.com/kasmvnc/docs/master/gpu_acceleration.html) allows you to specify the device to use IE `/dev/dri/renderD128` |
| DISABLE_IPV6 | If set to true or any value this will disable IPv6 | 
| LC_ALL | Set the Language for the container to run as IE `fr_FR.UTF-8` `ar_AE.UTF-8` |
| NO_DECOR | If set the application will run without window borders in openbox for use as a PWA. |
| NO_FULL | Do not autmatically fullscreen applications when using openbox. |

#### Optional run configurations

| Variable | Description |
| :----: | --- |
| `--privileged` | Will start a Docker in Docker (DinD) setup inside the container to use docker in an isolated environment. For increased performance mount the Docker directory inside the container to the host IE `-v /home/user/docker-data:/var/lib/docker`. |
| `-v /var/run/docker.sock:/var/run/docker.sock` | Mount in the host level Docker socket to either interact with it via CLI or use Docker enabled applications. |
| `--device /dev/dri:/dev/dri` | Mount a GPU into the container, this can be used in conjunction with the `DRINODE` environment variable to leverage a host video card for GPU accelerated applications. Only **Open Source** drivers are supported IE (Intel,AMDGPU,Radeon,ATI,Nouveau) |

### Language Support - Internationalization

The environment variable `LC_ALL` can be used to start this container in a different language than English simply pass for example to launch the Desktop session in French `LC_ALL=fr_FR.UTF-8`. Some languages like Chinese, Japanese, or Korean will be missing fonts needed to render properly known as cjk fonts, but others may exist and not be installed inside the container depending on what underlying distribution you are running. We only ensure fonts for Latin characters are present. Fonts can be installed with a mod on startup.

To install cjk fonts on startup as an example pass the environment variables (Alpine base):

```
-e DOCKER_MODS=linuxserver/mods:universal-package-install 
-e INSTALL_PACKAGES=fonts-noto-cjk
-e LC_ALL=zh_CN.UTF-8
```

The web interface has the option for "IME Input Mode" in Settings which will allow non english characters to be used from a non en_US keyboard on the client. Once enabled it will perform the same as a local Linux installation set to your locale.

### DRI3 GPU Acceleration (KasmVNC interface)

For accelerated apps or games, render devices can be mounted into the container and leveraged by applications using:

`--device /dev/dri:/dev/dri`

This feature only supports **Open Source** GPU drivers:

| Driver | Description |
| :----: | --- |
| Intel | i965 and i915 drivers for Intel iGPU chipsets |
| AMD | AMDGPU, Radeon, and ATI drivers for AMD dedicated or APU chipsets |
| NVIDIA | nouveau2 drivers only, closed source NVIDIA drivers lack DRI3 support |

The `DRINODE` environment variable can be used to point to a specific GPU.
Up to date information can be found [here](https://www.kasmweb.com/kasmvnc/docs/master/gpu_acceleration.html)

### Nvidia GPU Support (KasmVNC interface)

**Nvidia support is not compatible with Alpine based images as Alpine lacks Nvidia drivers**

Nvidia support is available by leveraging Zink for OpenGL support. This can be enabled with the following run flags:

| Variable | Description |
| :----: | --- |
| --gpus all | This can be filtered down but for most setups this will pass the one Nvidia GPU on the system |
| --runtime nvidia | Specify the Nvidia runtime which mounts drivers and tools in from the host |

The compose syntax is slightly different for this as you will need to set nvidia as the default runtime:

```
sudo nvidia-ctk runtime configure --runtime=docker --set-as-default
sudo service docker restart
```

And to assign the GPU in compose:

```
services:
  firefox:
    image: lscr.io/linuxserver/firefox:latest
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [compute,video,graphics,utility]
```

### Application management

#### PRoot Apps

If you run system native installations of software IE `sudo apt-get install filezilla` and then upgrade or destroy/re-create the container that software will be removed and the container will be at a clean state. For some users that will be acceptable and they can update their system packages as well using system native commands like `apt-get upgrade`. If you want Docker to handle upgrading the container and retain your applications and settings we have created [proot-apps](https://github.com/linuxserver/proot-apps) which allow portable applications to be installed to persistent storage in the user's `$HOME` directory and they will work in a confined Docker environment out of the box. These applications and their settings will persist upgrades of the base container and can be mounted into different flavors of KasmVNC based containers on the fly. This can be achieved from the command line with:

```
proot-apps install filezilla
```

PRoot Apps is included in all KasmVNC based containers, a list of linuxserver.io supported applications is located [HERE](https://github.com/linuxserver/proot-apps?tab=readme-ov-file#supported-apps).

#### Native Apps

It is possible to install extra packages during container start using [universal-package-install](https://github.com/linuxserver/docker-mods/tree/universal-package-install). It might increase starting time significantly. PRoot is preferred.

```yaml
  environment:
    - DOCKER_MODS=linuxserver/mods:universal-package-install
    - INSTALL_PACKAGES=libfuse2|git|gdb
```

## Usage

To help you get started creating a container from this image you can either use docker-compose or the docker cli.

>[!NOTE]
>Unless a parameter is flaged as 'optional', it is *mandatory* and a value must be provided.

### docker-compose (recommended, [click here for more info](https://docs.linuxserver.io/general/docker-compose))

```yaml
---
services:
  firefox-esr:
    image: carefulcomputer/firefox-esr:latest
    container_name: firefox-esr
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - FIREFOX_CLI=https://www.linuxserver.io/ #optional
    volumes:
      - /path/to/config:/config
    ports:
      - 3000:3000
      - 3001:3001
    shm_size: "1gb"
    restart: unless-stopped
```

### docker cli ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=firefox-esr \
  --security-opt seccomp=unconfined `#optional` \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e FIREFOX_CLI=https://www.linuxserver.io/ `#optional` \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /path/to/config:/config \
  --shm-size="1gb" \
  --restart unless-stopped \
  carefulcomputer/firefox-esr:latest
```

## Parameters

Containers are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 3000:3000` | Firefox ESR desktop gui. |
| `-p 3001:3001` | Firefox ESR desktop gui HTTPS. |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Etc/UTC` | specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-e FIREFOX_CLI=https://www.linuxserver.io/` | Specify one or multiple Firefox ESR CLI flags, this string will be passed to the application in full. |
| `-v /config` | Users home directory in the container, stores local files and settings |
| `--shm-size=` | This is needed for any modern website to function like youtube. |
| `--security-opt seccomp=unconfined` | For Docker Engine only, many modern gui apps need this to function on older hosts as syscalls are unknown to Docker. |

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```bash
-e FILE__MYVAR=/run/secrets/mysecretvariable
```

Will set the environment variable `MYVAR` based on the contents of the `/run/secrets/mysecretvariable` file.

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags), permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id your_user` as below:

```bash
id your_user
```

Example output:

```text
uid=1000(your_user) gid=1000(your_user) groups=1000(your_user)
```



## Support Info

* Shell access whilst the container is running:

    ```bash
    docker exec -it firefox-esr /bin/bash
    ```

* To monitor the logs of the container in realtime:

    ```bash
    docker logs -f firefox-esr
    ```

* Container version number:

    ```bash
    docker inspect -f '{{ index .Config.Labels "build_version" }}' firefox-esr
    ```

* Image version number:

    ```bash
    docker inspect -f '{{ index .Config.Labels "build_version" }}' carefulcomputer/firefox-esr:latest
    ```

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (noted in the relevant readme.md), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.

Below are the instructions for updating containers:

### Via Docker Compose

* Update images:
    * All images:

        ```bash
        docker-compose pull
        ```

    * Single image:

        ```bash
        docker-compose pull firefox-esr
        ```

* Update containers:
    * All containers:

        ```bash
        docker-compose up -d
        ```

    * Single container:

        ```bash
        docker-compose up -d firefox-esr
        ```

* You can also remove the old dangling images:

    ```bash
    docker image prune
    ```

### Via Docker Run

* Update the image:

    ```bash
    docker pull carefulcomputer/firefox-esr:latest
    ```

* Stop the running container:

    ```bash
    docker stop firefox-esr
    ```

* Delete the container:

    ```bash
    docker rm firefox-esr
    ```

* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images:

    ```bash
    docker image prune
    ```

### Image Update Notifications - Diun (Docker Image Update Notifier)

>[!TIP]
>We recommend [Diun](https://crazymax.dev/diun/) for update notifications. Other tools that automatically update containers unattended are not recommended or supported.

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:

```bash
git clone https://github.com/carefulcomputer/docker-firefox-dev.git
cd docker-firefox-dev
docker build \
  --no-cache \
  --pull \
  -t carefulcomputer/firefox-esr:latest .
```

The ARM variants can be built on x86_64 hardware and vice versa using `lscr.io/linuxserver/qemu-static`

```bash
docker run --rm --privileged lscr.io/linuxserver/qemu-static --reset
```

Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`.

## Credits

This project is based on the excellent work by the [LinuxServer.io](https://linuxserver.io) team. The original Firefox container and KasmVNC base image foundation provided the solid groundwork that made this customized Firefox ESR container possible.

**Original Project**: [linuxserver/docker-firefox](https://github.com/linuxserver/docker-firefox)  
**Base Image**: [linuxserver/docker-baseimage-kasmvnc](https://github.com/linuxserver/docker-baseimage-kasmvnc)

Special thanks to LinuxServer.io for:
- Creating the KasmVNC base image infrastructure
- Providing excellent containerization practices and patterns
- Maintaining high-quality Docker containers for the community
- Their commitment to open source and detailed documentation

If you find this container useful, consider supporting the original LinuxServer.io project:
- [LinuxServer.io Donations](https://opencollective.com/linuxserver)
- [LinuxServer.io GitHub](https://github.com/linuxserver)

## Versions

* **01.01.25:** - Switch to Firefox ESR with unsigned extension support. Add GitHub Actions workflow for automated builds.
  - Changed from Firefox regular to Firefox ESR
  - Added support for unsigned extensions (`xpinstall.signatures.required = false`)
  - Added multi-platform Docker builds (AMD64 + ARM64)
  - Updated Firefox settings path for ESR installation
* **25.09.24:** - Rebase to Ubuntu Noble.
* **23.05.24:** - Rebase to Alpine 3.20.
* **13.02.24:** - Add ability to pass CLI args to Firefox.
* **10.02.24:** - Update Readme with new env vars and ingest proper PWA icon.
* **01.01.24:** - Rebase to Alpine 3.19.
* **13.05.23:** - Rebase to Alpine 3.18.
* **18.03.23:** - Rebase to KasmVNC base image.
* **21.10.22:** - Rebase to Alpine 3.16, migrate to s6v3.
* **23.12.21:** - Rebase to Alpine 3.15, stop using ESR.
* **26.09.21:** - Rebase to Alpine 3.14.
* **19.04.21:** - Initial release.
