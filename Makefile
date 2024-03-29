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
		-v $(PWD):/data \
		-p 8888:8888 \
		$(IMAGE):$(1)-$(VERSION)

push-$(1): vars
	docker push $(IMAGE):$(1)-$(VERSION)
endef

$(foreach env,$(TAGS),$(eval $(call gen-env,$(env))))

build b: vars build-$(TAG) ## build image (or build-TAG)

run r: vars run-$(TAG) ## run the container locally (or: run-TAG)

## pa, push-all |> push all the images
pa push-all: version-check $(addprefix push-,$(TAGS)) push-readme
	@echo "done"

ba build-all: $(addprefix build-,$(TAGS)) ## build all the imaages

bootstrap: ## generate local conda environment
	micromamba create -p ./env -y \
		python conda-lock mamba ruamel.yaml jinja2

## l, locks |> rebuild all lock files
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
include .task.cfg.mk
