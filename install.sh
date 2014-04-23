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
	referer="http://ioquake3.org/extras/patch-data/"
	zipFile="http://ioquake3.org/data/quake3-latest-pk3s.zip"
	curl --referer $referer $zipFile > quake3-latest-pk3s.zip &&

	# unzip and rename the files
	unzip quake3-latest-pk3s.zip &&
	mv quake3-latest-pk3s ioquake3 &&

	# cleanup
	rm quake3-latest-pk3s.zip &&

	# everything went well
	return 0 ||

	# something went wrong
	return 1
}

download_iodfe() {
	# download and unzip
	curl -LOk https://github.com/Newbrict/iodfe/archive/master.zip &&
	unzip master.zip &&

	#cleanup
	rm master.zip &&

	# everything went well
	return 0 ||

	# something went wrong
	return 1
}

build_iodfe() {
	# build engine
	cd iodfe-master &&
	make &&

	# move engine into install directory
	mv build/release-linux-x86_64/iodfengine.x86_64 ../ioquake3/ &&

	# cleanup
	cd .. &&
	rm -rf iodfe-master/ &&

	# everything went well
	return 0 ||

	# something went wrong
	return 1
}

download_defrag() {
	# download and unzip
	cd ioquake3 &&
	curl http://q3defrag.org/files/defrag/defrag_${defragVersion}.zip > df.zip &&
	unzip df.zip &&

	# cleanup
	rm df.zip &&
	cd .. &&

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

	# move to root, clean up failed build
	cd .. &&
	rm -rf iodfe-master/ &&

	# download and install
	mkdir temporary &&

	# relative to the failed stuff
	cd temporary &&
	curl -LOk https://github.com/downloads/runaos/iodfe/iodfe-v3-lin-x86_64.tar.gz &&
	tar xvzf iodfe-v3-lin-x86_64.tar.gz &&

	# copy the file into ioquake directory
	mv iodfengine.x86_64 ../ioquake3/ &&

	# cleanup
	cd .. &&
	rm -rf temporary/ &&

	# everything went well
	return 0 ||

	# something went wrong
	return 1
}

failure() {
	echo $1
	exit 1
}

# get the config
source config

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
