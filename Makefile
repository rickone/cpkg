.PHONY: install

TargetPath=/usr/local/bin
Utils=cget cdep cmk
PWD=$(shell pwd)

install: $(Utils:%=$(TargetPath)/%)

$(TargetPath)/%: $(PWD)/%
	@ln -s $< $@