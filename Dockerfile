FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG FIREFOX_VERSION
LABEL build_version="Careful Computer version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="carefulcomputer"

# title
ENV TITLE=Firefox

# prevent Ubuntu's firefox stub from being installed
COPY /root/etc/apt/preferences.d/firefox-no-snap /etc/apt/preferences.d/firefox-no-snap

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/firefox-logo.png && \
  echo "**** install packages ****" && \
  apt-key adv \
    --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys 738BEB9321D1AAEC13EA9391AEBDF4819BE21867 && \
  echo \
    "deb https://ppa.launchpadcontent.net/mozillateam/ppa/ubuntu noble main" > \
    /etc/apt/sources.list.d/firefox.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    firefox-esr \
    ^firefox-esr-locale \
    python3-xdg && \
  echo "**** default firefox settings ****" && \
  FIREFOX_SETTING="/usr/lib/firefox-esr/browser/defaults/preferences/firefox.js" && \
  echo 'pref("datareporting.policy.firstRunURL", "");' > ${FIREFOX_SETTING} && \
  echo 'pref("datareporting.policy.dataSubmissionEnabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("datareporting.healthreport.service.enabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("datareporting.healthreport.uploadEnabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("trailhead.firstrun.branches", "nofirstrun-empty");' >> ${FIREFOX_SETTING} && \
  echo 'pref("browser.aboutwelcome.enabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("xpinstall.signatures.required", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("extensions.langpacks.signatures.required", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("extensions.experiments.enabled", true);' >> ${FIREFOX_SETTING} && \
  echo 'pref("extensions.webextensions.restrictedDomains", "");' >> ${FIREFOX_SETTING} && \
  echo 'pref("devtools.chrome.enabled", true);' >> ${FIREFOX_SETTING} && \
  echo 'pref("devtools.debugger.remote-enabled", true);' >> ${FIREFOX_SETTING} && \
  echo 'pref("extensions.webextensions.keepStorageOnUninstall", true);' >> ${FIREFOX_SETTING} && \
  echo 'pref("extensions.webextensions.keepUuidOnUninstall", true);' >> ${FIREFOX_SETTING} && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
