
| Provider | Type | Result |
| --- | --- | --- |
| CircleCI | test | [![CircleCI](https://circleci.com/gh/xriss/gamecake.svg?style=svg)](https://circleci.com/gh/xriss/gamecake) |


Be sure to clone repo with submodules as the engine binaries live in a 
permanently orphaned branch. The following is the optimal way to git 
clone so that the submodule references master rather than downloading 
the repo twice.

	git clone https://github.com/xriss/gamecake.git
	cd gamecake
	./git-init

The submodules also need care when pulling updates, use this script to 
get the latest everything.

	./git-pull


Autogenerated lua code documentation can be found at 
https://xriss.github.io/gamecake/ but not everything is fully 
documented here yet.

Releases are cross compiled (win32/emscripten/nacl) using build/*/make 
scripts or built using the vbox_* directories 
(linux32/linux64/osx64/raspi) which contain vagrant or qemu boxes setup 
to build the code in a controlled environment via a ./make script. The 
latest code built this way can be found in the exe branch and a zip of 
them all can be downloaded from https://github.com/xriss/gamecake/archive/exe.zip

For a linuxy build, the required lib dependencies are luajit and SDL2. 
Install these then you may use the following scripts to make and 
install. (we also need premake but binaries that probably work are 
included)

	./make
	sudo ./install

Once built the engine lives in one single fat binary that includes many 
lua libraries. For convenience gamecake is a command line compatible 
replacement for lua and pagecake is a command line compatible 
replacement for nginx (open resty). The only diference is we have C 
libraries and Lua libraries from this repository embedded and ready to 
be required by your lua code.
