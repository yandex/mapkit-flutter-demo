#!/bin/bash

set -eu

BUILD_ANDROID=""
BUILD_IOS=""

while [ -n "${1-}" ]
do
    case "$1" in
        --android)
            BUILD_ANDROID="1"
            ;;
        --ios)
            BUILD_IOS="1"
            ;;
    esac
    shift
done

ARCADIA_ROOT="$PWD"
while [[ ! -e "$ARCADIA_ROOT/.arcadia.root" ]]; do
    if [[ "ARCADIA_ROOT" == "/" ]]; then
        echo "Could not find arcadia root"
        exit 1
    fi
    ARCADIA_ROOT="$(dirname "$ARCADIA_ROOT")"
done

cd "$ARCADIA_ROOT/maps/mobile/apps/public_repos/yandex/mapkit-flutter-demo/navikit-demo"
rm -Rf bundle
mkdir bundle

if [ -n "$BUILD_ANDROID" ]
then
    PACKAGE_NAME="$ARCADIA_ROOT/maps/mobile/ci/releases/navikit-public-dart-android.pkg.json"

    mkdir bundle/out-android
    "$ARCADIA_ROOT/ya" package --checkout --tar --raw-package-path bundle/out-android $PACKAGE_NAME
    mv bundle/out-android/yandex_maps bundle/yandex_maps
    rm -Rf bundle/out-android
fi

if [ -n "$BUILD_IOS" ]
then
    PACKAGE_NAME="$ARCADIA_ROOT/maps/mobile/ci/releases/navikit-public-dart-ios.pkg.json"

    mkdir bundle/out-ios
    "$ARCADIA_ROOT/ya" package --checkout --tar --raw-package-path bundle/out-ios $PACKAGE_NAME

    if [ -n "$BUILD_ANDROID" ]; then
        mv bundle/out-ios/yandex_maps/ios/Classes bundle/yandex_maps/ios
        mv bundle/out-ios/yandex_maps/ios/Frameworks/* bundle/yandex_maps/ios/Frameworks
    else
        mv bundle/out-ios/yandex_maps bundle/yandex_maps
    fi

    rm -Rf bundle/out-ios
fi

flutter clean
cd bundle/yandex_maps
flutter pub run build_runner build
