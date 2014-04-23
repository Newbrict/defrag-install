#!/bin/bash

defragVersion="1.91.22"

check_dependancies() {
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

check_dependancies
download_pk3s
download_iodfe
build_iodfe
download_defrag
