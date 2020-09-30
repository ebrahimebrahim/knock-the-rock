#!/bin/bash

set -e




GODOT_PROJECT_DIR=ktr 
BUILD_DIR_G=../build  # This is build directory relative to GODOT_PROJECT_DIR
BUILD_DIR=$GODOT_PROJECT_DIR/$BUILD_DIR_G

BUILD_SUBDIR_WIN=windows
BUILD_SUBDIR_LIN=linux
BUILD_SUBDIR_MAC=macos

EXEC_WIN="Knock the Rock.exe"
EXEC_LIN="Knock the Rock.x86_64"
EXEC_MAC="Knock the Rock.zip"

# for setting the windows icon
RCEDIT=rcedit/rcedit-x64.exe
ICO=ktr/icon.ico

COMMIT_HASH_FILE=$GODOT_PROJECT_DIR/commit_hash.txt


function cleanup {
    rm -f $COMMIT_HASH_FILE
}
trap cleanup EXIT


if [ -z $GODOT ]
then
    echo "Error: Set your environment variable \$GODOT to point to the Godot executable"
    exit 1
fi


git rev-parse HEAD > $COMMIT_HASH_FILE


rm -rf $BUILD_DIR
mkdir $BUILD_DIR
mkdir $BUILD_DIR/$BUILD_SUBDIR_WIN
mkdir $BUILD_DIR/$BUILD_SUBDIR_LIN
mkdir $BUILD_DIR/$BUILD_SUBDIR_MAC

$GODOT --path $GODOT_PROJECT_DIR --export "Linux/X11" "$BUILD_DIR_G/$BUILD_SUBDIR_LIN/$EXEC_LIN"
cp ktr/icon.png $BUILD_DIR/$BUILD_SUBDIR_LIN

$GODOT --path $GODOT_PROJECT_DIR --export "Mac OSX" "$BUILD_DIR_G/$BUILD_SUBDIR_MAC/$EXEC_MAC"
$GODOT --path $GODOT_PROJECT_DIR --export "Windows Desktop" "$BUILD_DIR_G/$BUILD_SUBDIR_WIN/$EXEC_WIN"

# for setting the windows icon
if [ -z $(command -v wineconsole) ]
then
		echo "wineconsole not installed, windows icon has not been set!"
else
		echo "wineconsole found, setting windows icon..."
		wineconsole $RCEDIT "$BUILD_DIR/$BUILD_SUBDIR_WIN/$EXEC_WIN" --set-icon $ICO
fi





