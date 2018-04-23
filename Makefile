head ?= $(shell git rev-parse --short HEAD)
today ?= $(shell date +%Y-%m-%d)

.PHONY: build check clean deploy preview rebuild server watch
build:   ; stack exec site build
check:   ; stack exec site check
clean:   ; stack exec site clean
deploy:  ; stack exec site deploy
preview: ; stack exec site preview
rebuild: ; stack exec site rebuild
server:  ; stack exec site server
watch:   ; stack exec site watch

.PHONY: new-post
new-post: posts
	@read -p "title: " title; touch posts/$(today)-$$title.md

.PHONY: new-draft
new-draft: drafts
	@read -p "title: " title; touch drafts/$(today)-$$title.md

#
# Publication
#

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

drafts:
	mkdir drafts

posts:
	mkdir posts

_site:
	git submodule init
	git submodule update
