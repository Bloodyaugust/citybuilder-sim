#!/bin/sh

# set -e

which butler

echo "Checking application versions..."
echo "-----------------------------"
cat ~/.local/share/godot/templates/4.0-rc2/version.txt
godot --version
butler -V
echo "-----------------------------"

mkdir build/
mkdir build/linux/
mkdir build/osx/
mkdir build/win/

echo "EXPORTING FOR LINUX"
echo "-----------------------------"
godot --headless --export-debug "Linux/X11" build/linux/citybuilder-sim-4.x86_64 -v
# echo "EXPORTING FOR OSX"
# echo "-----------------------------"
# godot --export "Mac OSX" build/osx/citybuilder-sim-4.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --headless --export-debug "Windows Desktop" build/win/citybuilder-sim-4.exe -v
echo "-----------------------------"

# echo "CHANGING FILETYPE AND CHMOD EXECUTABLE FOR OSX"
# echo "-----------------------------"
# cd build/osx/
# mv citybuilder-sim-4.dmg citybuilder-sim-4-osx-alpha.zip
# unzip citybuilder-sim-4-osx-alpha.zip
# rm citybuilder-sim-4-osx-alpha.zip
# chmod +x citybuilder-sim-4.app/Contents/MacOS/citybuilder-sim-4
# zip -r citybuilder-sim-4-osx-alpha.zip citybuilder-sim-4.app
# rm -rf citybuilder-sim-4.app
# cd ../../

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "ZIPPING FOR WINDOZE"
echo "-----------------------------"
cd build/win/
zip -r citybuilder-sim-4-win-alpha.zip citybuilder-sim-4.exe citybuilder-sim-4.pck
rm -r citybuilder-sim-4.exe citybuilder-sim-4.pck
cd ../../

echo "ZIPPING FOR LINUX"
echo "-----------------------------"
cd build/linux/
zip -r citybuilder-sim-4-linux-alpha.zip citybuilder-sim-4.x86_64 citybuilder-sim-4.pck
rm -r citybuilder-sim-4.x86_64 citybuilder-sim-4.pck
cd ../../

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/citybuilder-sim:linux-alpha
# butler push build/osx/ synsugarstudio/citybuilder-sim:osx-alpha
butler push build/win/ synsugarstudio/citybuilder-sim:win-alpha
