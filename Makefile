all: libpasta-sync wheels

libpasta-sync:
	git submodule update --init --recursive
ifneq ($(shell git -C pasta-bindings/ rev-parse --abbrev-ref HEAD),master)
	cd pasta-bindings && git fetch && git checkout origin/master
endif
	make -C pasta-bindings libpasta-sync

wheels:
	docker run --rm -v `pwd`:/io quay.io/pypa/manylinux1_x86_64 /io/build-wheels.sh
	# docker run --rm -v `pwd`:/io samjs/manylinux1_x86_64/rust /io/build-wheels.sh
	@echo "Now run `twine upload wheelhouse/*` to upload"

.PHONY: libpasta-sync wheels