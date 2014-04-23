#!/bin/bash

check_dependencies() {
	which curl &&
	which git &&

	# everything went well
	return 0 ||

	# something went wrong
	return 1
}

download_pk3s() {
	# by downloading this you agree to the UELA:
	# http://ioquake3.org/extras/patch-data/
	referer="http://ioquake3.org/extras/patch-data/" &&
	zipFile="http://ioquake3.org/data/quake3-latest-pk3s.zip" &&
	cd $base/temporary/ &&
	curl --referer $referer $zipFile > quake3-latest-pk3s.zip &&

	# unzip and rename the files
	unzip quake3-latest-pk3s.zip &&
	mv quake3-latest-pk3s $base/ioquake3 &&

	# everything went well
	return 0 ||

	# something went wrong
	return 1
}

download_iodfe() {
	# download and unzip
	cd $base/temporary/ &&
	curl -LOk https://github.com/Newbrict/iodfe/archive/master.zip &&
	unzip master.zip &&

	# everything went well
	return 0 ||

	# something went wrong
	return 1
}

build_iodfe() {
	# build engine
	cd $base/temporary/iodfe-master/ &&
	make &&

	# move engine into install directory
	mv build/release-linux-x86_64/iodfengine.x86_64 $base/ioquake3/ &&

	# everything went well
	return 0 ||

	# something went wrong
	return 1
}

download_defrag() {
	# download and unzip
	cd $base/temporary/ &&
	curl http://q3defrag.org/files/defrag/defrag_${defragVersion}.zip > df.zip &&
	unzip df.zip &&

	mv defrag/ $base/ioquake3/ &&
	# everything went well
	return 0 ||

	# something went wrong
	return 1
}

backup_iodfe() {
	# check to see if they want to get the backup iodfe
	echo "Something went wrong during the iodfe build" &&
	echo "Would you like to download a precompiled iodfe? [y/n]" &&
	read response &&
	[[ $response =~ ^[yY]$ ]] &&

	# relative to the failed stuff
	cd $base/temporary/ &&
	curl -LOk https://github.com/downloads/runaos/iodfe/iodfe-v3-lin-i386.tar.gz &&
	curl -LOk https://github.com/downloads/runaos/iodfe/iodfe-v3-lin-x86_64.tar.gz &&
	tar xvzf iodfe-v3-lin-x86_64.tar.gz &&
	tar xvzf iodfe-v3-lin-i386.tar.gz &&

	# copy the file into ioquake directory
	mv iodfengine.x86_64 $base/ioquake3/ &&
	mv iodfengine.i386 $base/ioquake3/ &&

	# everything went well
	return 0 ||

	# something went wrong
	return 1
}

cleanup() {
	echo "cleaning up temporary files..."
	cd $base
	rm -r $tempDir
	echo "all clean :)"
}

failure() {
	echo $1
	cleanup
	exit 1
}

# get the config
source config
mkdir $tempDir

echo "Checking Dependencies"
check_dependencies ||
failure "Dependencies required to run the script are missing"

echo "Downloading ioquake data"
download_pk3s ||
failure "Something went wrong during ioquake data download"

echo "Downloading iodfe"
download_iodfe ||
failure "Something went wrong during the iodfe download"

echo "Building iodfe"
build_iodfe ||
backup_iodfe ||
failure "Something went wrong during the iodfe build"

echo "Downloading defrag"
download_defrag ||
failure "Something went wrong during the DeFRaG download"

# cleanup temp file
cleanup
