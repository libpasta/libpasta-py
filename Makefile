all: libpasta-sync wheels

libpasta-sync:
	git submodule init
	git fetch --all
ifneq ($(shell git -C pasta-bindings/ rev-parse --abbrev-ref HEAD),master)
	cd pasta-bindings && git fetch && git checkout origin/master
endif
	make -C pasta-bindings libpasta-sync

libpasta: libpasta-sync
	USE_STATIC=1 make -C pasta-bindings libpasta python

wheels: libpasta
	docker run --rm -v `pwd`:/io quay.io/pypa/manylinux1_x86_64 /io/build-wheels.sh
	# docker run --rm -v `pwd`:/io samjs/manylinux1_x86_64/rust /io/build-wheels.sh
	@echo "Now run \"twine upload wheelhouse/*\" to upload"

.PHONY: libpasta-sync wheels