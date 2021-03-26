.PHONY: tarball

tarball:
	docker build --progress=plain --target=Tarball -t cloudv/icestorm:tarball .
	docker run --rm -v $(PWD):$(PWD) -w $(PWD) cloudv/icestorm:tarball /bin/bash -c "cp /icestorm.tar.xz ."