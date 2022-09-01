VERSION ?= $(shell git describe --tags --always --dirty | sed s'/dirty/dev/')
IMAGE := daylinmorgan/scrna
TAGS := minimal full
TAG ?= full


SHAREDRULES = build run push b r p

define gen-env
.PHONY: $(addsuffix -$(1), $(SHAREDRULES))
# add aliases
b-$(1): build-$(1)
r-$(1): run-$(1)
p-$(1): push-$(1)

build-$(1): locks/$(1).lock
	@docker build --build-arg LOCKFILE=$$< --tag $(IMAGE):$(1)-$(VERSION) .

run-$(1):
	@docker run --rm -it \
		-u $(shell id -u):$(shell id -g) \
		-v $(PWD):/data \
		-p 8888:8888 \
		$(IMAGE):$(1)-$(VERSION)

push-$(1): params
	docker push $(IMAGE):$(1)-$(VERSION)
endef

$(foreach env,$(TAGS),$(eval $(call gen-env,$(env))))

## b, build | build image (or build-TAG)
.PHONY: build
build b: params build-$(TAG)

## r, run | run the container locally (or: run-TAG)
.PHONY: run r
run r: params run-$(TAG)

## push-all | push all the images
.PHONY: push
push-all: version-check $(addprefix push-,$(TAGS)) push-readme
	@echo "done"

## build-all | build all the imaages
.PHONY: build-all
build-all: $(addprefix build-,$(TAGS))

## bootstrap | generate local conda environment
.PHONY: bootstrap
bootstrap:
	mamba create --force -p ./env -y \
		python conda-lock mamba ruamel.yaml jinja2

## l, locks | rebuild all lock files
.PHONY: locks
locks l: $(foreach tag,$(TAGS), locks/$(tag).lock)

locks/%.lock: specs/%.yml
	conda-lock lock -p linux-64 --mamba --kind explicit \
		-f $< --filename-template $@

.PHONY: version-check
version-check:
	@if [[ "${VERSION}" == *'-'* ]];then\
		echo ">> version is invalid: $(VERSION)"; exit 1;\
	else \
		echo ">> version checks out";\
	fi

.PHONY: push-readme
push-readme: README-containers.md
	@docker pushrm $(IMAGE)

%.md: tmpl/%.tmpl.md
	@./scripts/generate-readme.py $(VERSION) $*.tmpl.md > $@

.PHONY: clean
clean c:
	@rm -f *.{svg,png}
	@rm -f README-containers.md

.DEFAULT_GOAL := help
## h, help | show this help
.PHONY: help h
help h: Makefile params
	@awk -v fill=$(shell sed -n 's/^## \(.*\) | .*/\1/p' $< | wc -L)\
  	'match($$0,/^## (.*) \|/,name) && match($$0,/\| (.*)$$/,help)\
  	{printf "\033[36m%*s\033[0m | \033[30m%s\033[0m\n",\
    fill,name[1],help[1];} match($$0,/^### (.*)/,str) \
	{printf "%*s   \033[30m%s\033[0m\n",fill," ",str[1];}' $<

.PHONY: params
params:
	@printf "\033[35mCurrent Params\033[0m:\n\n"
	@printf "  IMAGE: %s\n" $(IMAGE)
	@printf "  VERSION: %s\n" $(VERSION)
	@printf "  TAG: %s | choices: %s\n\n" $(TAG) "$(TAGS)"
