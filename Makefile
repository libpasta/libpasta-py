all: wheels

libpasta:
	USE_STATIC=1 make -C ../pasta-bindings python

wheels: libpasta
	docker run --rm -v `pwd`:/io -v `pwd`/../libpasta/:/libpasta -v `pwd`/../pasta-bindings/:/pasta-bindings quay.io/pypa/manylinux1_x86_64 /io/build-wheels.sh
	# docker run --rm -v `pwd`:/io -v `pwd`/../libpasta/:/libpasta -v `pwd`/../pasta-bindings/:/pasta-bindings  samjs/manylinux1_x86_64/rust /io/build-wheels.sh
	@echo "Now run \"twine upload wheelhouse/*\" to upload"

.PHONY: wheels