head ?= $(shell git rev-parse --short HEAD)

.PHONY: clean
clean:
	stack exec site clean

.PHONY: build
build:
	stack exec site build

.PHONY: pre-publish
pre-publish: | clean _site
	@if [ -n "$(shell git status --porcelain)" ]; then \
		echo "commit unstaged changes before publishing"; \
		exit 1; \
	fi

.PHONY: commit
commit:
	(cd _site && \
		git checkout master && \
		git add --all && \
		git commit -m "publish from $(head)" && \
		git push origin master)

.PHONY: publish
publish: | pre-publish build commit
	git add _site
	git commit -m "published"
	git push origin hakyll

#
# Files
#

_site:
	git submodule init
	git submodule update
