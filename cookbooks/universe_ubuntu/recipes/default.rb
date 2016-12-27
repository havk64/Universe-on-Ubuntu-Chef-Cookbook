#
# Cookbook Name:: universe_ubuntu
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'apt::default'

user = node['universe']['user']
home = node['universe']['home']

apt_repository 'newer golang apt repo' do
  uri 'ppa:ubuntu-lxc/lxd-stable'
  only_if { node['platform_version'] == '14.04' }
end

packages = %w(golang
              libjpeg-turbo8-dev
              make
              tmux
              htop
              chromium-browser
              git
              cmake
              zlib1g-dev
              libjpeg-dev
              xvfb
              libav-tools
              xorg-dev
              python-opengl
              libboost-all-dev
              libsdl2-dev
              swig)

packages.each { |item| package item }

remote_file "#{Chef::Config[:file_cache_path]}/Anaconda3-4.2.0-Linux-x86_64.sh" do
  owner user
  group user
  mode '0755'
  source 'https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh'
  checksum '73b51715a12b6382dd4df3dd1905b531bd6792d4aa7273b2377a0436d45f0e78'
  action :create_if_missing
end

execute 'install_anaconda' do
  user user
  command "bash #{Chef::Config[:file_cache_path]}/Anaconda3-4.2.0-Linux-x86_64.sh -b"
  not_if "[ -x #{home}/anaconda3/bin/conda ]"
end

ruby_block 'Add anaconda to the PATH' do
  block do
    file = Chef::Util::FileEdit.new "#{home}/.bashrc"
    file.insert_line_if_no_match(%r{#{home}/anaconda3/bin:\$PATH"$},
    "export PATH=\"#{home}/anaconda3/bin:$PATH\"")
    file.write_file
  end
end

cookbook_file "#{home}/environment.yml" do
  source 'environment.yml'
end

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
