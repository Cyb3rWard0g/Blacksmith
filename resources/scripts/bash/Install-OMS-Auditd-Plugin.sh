#! /bin/sh

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

usage()
{
    echo "usage: $1 [OPTIONS]"
    echo "Options:"
    echo "   "
    echo "  -t tag --tag tag           Download bundle script from specific GitHub release tag (i.e v2.4.5-44)."
    echo "                             Latest version is installed by default"
    echo "  -? | -h | --help           shows this usage text."
}

# Extract parameters
while [ $# -ne 0 ]
do
  case "$1" in
    -t|--tag)
      tagRelease=$2
      shift 2
      ;;

    -\? | -h | --help)
      usage `basename $0` >&2
      exit 0
      ;;

    *)
      echo "Unknown argument: '$1'" >&2
      echo "Use -h or --help for usage" >&2
      exit 1
      ;;
  esac
done

# We need to use sudo for commands in the following block, if not running as root
SUDO=''
if [ "$EUID" != 0 ]; then
    SUDO='sudo'
fi

# Set bundle script to latest GitHub release:
GITHUB_RELEASE_X64=$(curl --silent "https://api.github.com/repos/microsoft/OMS-Auditd-Plugin/releases/latest" | grep -oP '"browser_download_url": "\K(.*.sh)(?=")')
# Output example: https://github.com/microsoft/OMS-Auditd-Plugin/releases/download/v2.4.5-44/auoms-2.4.5-44.universal.x64.sh
BUNDLE_X64=$(basename $GITHUB_RELEASE_X64)
# Output example: auoms-2.4.5-44.universal.x64.sh

if [ -n "$tagRelease" ]; then
  ASSETS_URL=$(curl --silent "https://api.github.com/repos/microsoft/OMS-Auditd-Plugin/releases/tags/$tagRelease" | grep -oP '"assets_url": "\K(.*)(?=")')
  GITHUB_RELEASE_X64=$(curl --silent "$ASSETS_URL" | grep -oP '"browser_download_url": "\K(.*.sh)(?=")')
  BUNDLE_X64=$(basename $GITHUB_RELEASE_X64)
fi
wget -O ${BUNDLE_X64} ${GITHUB_RELEASE_X64} && $SUDO sh ./${BUNDLE_X64} "--install"