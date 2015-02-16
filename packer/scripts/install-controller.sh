#!/bin/bash

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
apt-add-repository -y ppa:chris-lea/redis-server

apt-get update
apt-get -fy install lxc-docker screen redis-server

#Setup startup scripts