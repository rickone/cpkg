.PHONY: install

PWD=${shell pwd}

install:
	@chmod +x cpkg
	@ln -s ${PWD}/cpkg /usr/local/bin/cpkg
