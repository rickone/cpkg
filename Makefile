.PHONY: install

PWD=${shell pwd}

install:
	@chmod +x cpkg
	@cd /usr/local/bin && ln -s ${PWD}/cpkg cpkg
	@cd /usr/local/etc && ln -s ${PWD}/cmk cmk
