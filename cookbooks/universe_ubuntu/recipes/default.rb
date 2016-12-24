#
# Cookbook Name:: universe-ubuntu
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'apt::default'

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

remote_file '/tmp/Anaconda3-4.2.0-Linux-x86_64.sh' do
  source 'https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh'
  checksum '73b51715a12b6382dd4df3dd1905b531bd6792d4aa7273b2377a0436d45f0e78'
end

execute 'install_anaconda' do
  user 'vagrant'
  command 'bash /tmp/Anaconda3-4.2.0-Linux-x86_64.sh -b'
  not_if '[ -x /home/vagrant/anaconda3/bin/conda ]'
end

ruby_block 'Add anaconda to the PATH' do
  block do
    file = Chef::Util::FileEdit.new '/home/vagrant/.bashrc'
    file.insert_line_if_no_match(/home\/$USER\/anaconda3\/bin:$PATH/,
    %q(export PATH="/home/$USER/anaconda3/bin:$PATH"))
    file.write_file
  end
end

cookbook_file '/home/vagrant/environment.yml' do
  source 'environment.yml'
end

apt_repository "docker" do
  uri 'https://apt.dockerproject.org/repo'
  distribution "#{node['platform']}-#{node['lsb']['codename']}"
  components ["main"]
  key 'https://apt.dockerproject.org/gpg'
end

docker_pkgs = ["linux-image-extra-#{node['os_version']}",
               "linux-image-extra-virtual",
               "docker-engine"]

docker_pkgs.each { |item| package item }
