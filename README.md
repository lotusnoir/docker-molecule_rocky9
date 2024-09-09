# Docker Image with rocky9 base image 

This repo was created in order to test ansible roles with molecule.

## Build it locally

  docker build -t rocky9img .
  docker run -d -name rocky9con --cgroupns=host --volume=/sys/fs/cgroup:/sys/fs/cgroup:rw rocky9img
  docker exec -it rocky9con bash


## Use it from dockerhub

    https://hub.docker.com/repository/docker/lotusnoir/ansible_molecule_test_images:rocky9
