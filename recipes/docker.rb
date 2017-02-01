#
# Cookbook Name:: universe_ubuntu
# Recipe:: docker
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

include_recipe 'apt::default'

apt_repository 'docker' do
  uri 'https://apt.dockerproject.org/repo'
  distribution "#{node['platform']}-#{node['lsb']['codename']}"
  components ['main']
  key 'https://apt.dockerproject.org/gpg'
end

docker_pkgs = ["linux-image-extra-#{node['os_version']}",
               'linux-image-extra-virtual',
               'docker-engine']

docker_pkgs.each { |item| package item }

service 'docker' do
  action :nothing
end

service 'lightdm' do
  action :nothing
end

group 'docker' do
  action :modify
  append true
  members node['universe']['user']['name']
  notifies :restart, 'service[docker]', :immediately
  notifies :restart, 'service[lightdm]', :immediately
end
