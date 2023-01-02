#!/usr/bin/env bash
export QT_VERSION=6.4.0
export QT_PATH=/opt/Qt
export QT_MACOS=${QT_PATH}/${QT_VERSION}/macos
export AQT_VERSION="aqtinstall==3.0.1"
export PATH=$PATH:${QT_PATH}/Tools/CMake/bin:${QT_PATH}/Tools/Ninja:${QT_PATH}/${QT_VERSION}/macos/bin:/opt/osxcross/bin