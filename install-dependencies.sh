#!/bin/sh
set -eu

echo "==> Updating package lists"
opkg update

echo
echo "==> Installing Beryl patch dependencies"

opkg install \
    git \
    git-http \
    patch

echo
echo "==> Dependencies installed successfully."
