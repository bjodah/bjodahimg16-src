# Personal Docker image useful for scientific computing

This is the [bjodahimg16-src](https://github.com/bjodah/bjodahimg16-src) repo.
It contains scripts and templates for:

  - [bjodahimg16base-dockerfile](https://github.com/bjodah/bjodahimg16base-dockerfile)
  - [bjodahimg16-dockerfile](https://github.com/bjodah/bjodahimg16-dockerfile)
  - [bjodahimg16dev-dockerfile](https://github.com/bjodah/bjodahimg16dev-dockerfile)

Each of the images are based on the previous, with bjodahimg16base
being based on Ubuntu 16.04 LTS. Dependencies not in Ubuntu
repositories are tracked in [source tree](./environment/resources) for
easier reproducibility (Ubuntu repository mirrors are widespread and
expected to be available for the foreseeable future).

## How to build the images

First `bjodahimg16base` is built (with compilers):

```
$ ./tools/03_download_base_python_packages.sh  # check for duplicates
$ ./tools/04_upload_base_to_repo.sh latest
$ ./tools/05_generate_base_Dockerfile.sh latest
$ ./tools/10_build_base_image.sh latest dummy_reg_user
```

If tests pass above, then the generated Dockerfile is check in and
pushed to github to trigger a trusted build on hub.docker.com (yes,
the build pulls binary blobs from a server I control, so "trusted"
refers to you trusting me). Now we build the main image using the
compilers provided by the base image:

```
$ ./tools/20_download_python_packages.sh
$ ./tools/30_download_blobs.sh
$ ./tools/35_render_build_scripts.sh
$ ./tools/40_build_packages.sh
$ ./tools/60_upload_to_repo.sh latest
$ ./tools/70_generate_Dockerfile.sh latest
$ ./tools/80_build_image.sh latest dummy_reg_user
$ ./tools/85_test_image.sh latest dummy_reg_user
```

See [deb-buildscripts/](deb-buildscripts/) for packages built by
[tools/40_build_packages.sh](tools/40_build_packages.sh).

If tests pass in the last step the new ``Dockerfile`` is commited in
git and pushed to [bjodahimg-dockerfile](https://github.com/bjodah/bjodahimg-dockerfile) 
which triggers a trusted build on
[docker hub](https://hub.docker.com/r/bjodah/bjodahimg).

Finally I have a volatile image (```bjodahimg16dev```) which is built from the main image:
```
$ ./tools/90_generate_dev_Dockerfile.sh latest
$ ./tools/93_build_dev_image.sh latest dummy_reg_user
$ ./tools/96_test_dev_image.sh latest dummy_reg_user
```
With volatile I mean that it is a moving target, still useful
for e.g. CI-servers but not as long-term reproducibility dependency.

## How to tag a new release
```
$ ssh repo@hera.physchem.kth.se 'rm public_html/bjodahimg16/latest'
$ ./tools/70_generate_Dockerfile.sh vX.Y
$ ./tools/80_build_image.sh vX.Y dummy_reg_user
$ ssh repo@hera.physchem.kth.se 'mkdir public_html/bjodahimg/vX.YY; ln -s vX.YY public_html/latest'
$ cd bjodahimg-dockerfile
$ git commit -am "various updates for release vX.Y"
$ git tag -a vX.Y -m vX.Y
$ git push
$ git push --tags
$ cd ../
$ git commit -am "new release X.Y"
$ git push
```
