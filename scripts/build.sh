#!/bin/bash

set -e

mkdir -p builds

for dir in Packwiz/*; do
    if [ -d "$dir" ]; then
        VERSION=$(basename "$dir")

        echo "Building Minecraft $VERSION pack..."

        cd "./$dir"

        PACK_VERSION=$(grep '^version' pack.toml | cut -d '"' -f2)

        packwiz refresh
        packwiz modrinth export -o ../../builds/lucidly-optimised-$VERSION-$PACK_VERSION.mrpack
        packwiz curseforge export -o ../../builds/lucidly-optimised-$VERSION-$PACK_VERSION.zip

        cd ../../
    fi
done

echo "All builds complete."