#!/bin/sh

if [ ! -f Makefile ]; then
	./config
fi

make -j 4

if [ ! -d lib ]; then
	mkdir lib
	cp libcrypto.a libcrypto.dylib libssl.a libssl.dylib lib
fi
