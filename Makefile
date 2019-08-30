
.PHONY: docker clean shell test-install test

pyversions := 3.6 3.7
gdalversions := 2.4 3

combo := $(foreach pyv,$(pyversions),$(foreach gdalv,$(gdalversions),$(pyv)-$(gdalv)))

export ODC_DOCKER_TAG ?= conda-forge



docker:
	docker build -t opendatacube/datacube-core:$(ODC_DOCKER_TAG) -f docker/$(ODC_DOCKER_TAG)/Dockerfile .

docker-test:
	docker-compose -f docker/docker-compose-test.yml run --rm odc

clean:
	find . -name __pycache__ | xargs rm -rf
	rm -rf .hypothesis

test:
	pytest -r a --cov datacube --doctest-ignore-import-errors --durations=5 datacube tests datacube_apps integration_tests


shell:
	docker run -it -w /tmp/code -v $(CURDIR):/tmp/code --rm opendatacube/datacube-core:conda-forge bash


test-install:
	pip install '.[test,celery,s3]'
	pip install ./tests/drivers/fail_drivers --no-deps --upgrade

update-deps:
	$(MAKE) -C requirements environment.conda-forge.3.6-2.4.yml