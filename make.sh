#!/bin/bash

set -e



GODOT_PROJECT_DIR=ktr 
BUILD_DIR_G=../build  # This is build directory relative to GODOT_PROJECT_DIR
BUILD_DIR=$GODOT_PROJECT_DIR/$BUILD_DIR_G

COMMIT_HASH_FILE=$GODOT_PROJECT_DIR/commit_hash.txt
VERSION=$(cat ktr/version_number.txt)

ARCHIVE_NAME=knock_the_rock_$VERSION

BUILD_SUBDIR_WIN=${ARCHIVE_NAME}_windows
BUILD_SUBDIR_LIN=${ARCHIVE_NAME}_linux
BUILD_SUBDIR_MAC=${ARCHIVE_NAME}_macos
RELEASE_SUBDIR=release

EXEC_WIN="Knock the Rock.exe"
EXEC_LIN="Knock the Rock.x86_64"

# for setting the windows icon
RCEDIT=rcedit/rcedit-x64.exe
ICO=ktr/icon.ico



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
mkdir $BUILD_DIR/$RELEASE_SUBDIR


# --- Linux ---

$GODOT --path $GODOT_PROJECT_DIR --export "Linux/X11" "$BUILD_DIR_G/$BUILD_SUBDIR_LIN/$EXEC_LIN"
cp ktr/icon.png "$BUILD_DIR/$BUILD_SUBDIR_LIN"
cd $BUILD_DIR
tar cfvz $RELEASE_SUBDIR/$BUILD_SUBDIR_LIN.tar.gz $BUILD_SUBDIR_LIN
cd ..



# --- Mac OS ---

$GODOT --path $GODOT_PROJECT_DIR --export "Mac OSX" "$BUILD_DIR_G/$RELEASE_SUBDIR/$BUILD_SUBDIR_MAC.zip"


# --- Windows ---

$GODOT --path $GODOT_PROJECT_DIR --export "Windows Desktop" "$BUILD_DIR_G/$BUILD_SUBDIR_WIN/$EXEC_WIN"

# for setting the windows icon
if [ -z $(command -v wineconsole) ]
then
		echo "wineconsole not installed, windows icon has not been set!"
else
		echo "wineconsole found, setting windows icon..."
		wineconsole $RCEDIT "$BUILD_DIR/$BUILD_SUBDIR_WIN/$EXEC_WIN" --set-icon $ICO
fi


cd $BUILD_DIR
zip -r $RELEASE_SUBDIR/$BUILD_SUBDIR_WIN.zip $BUILD_SUBDIR_WIN
cd ..



