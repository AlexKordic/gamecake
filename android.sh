cd `dirname $0`

#simple forced nacl build, just to see if we can get somewhere with this

ansdk=../sdks/android-8-arm
export PATH=$ansdk/arm-linux-androideabi/bin:$PATH

#so premake knows that it is a nacl build
build/premake4 gmake android

#perform a build
cd build-gmake-android

if [ "$1" == "release" ] ; then
	make config=release
else
	make $*
fi

cd ..

