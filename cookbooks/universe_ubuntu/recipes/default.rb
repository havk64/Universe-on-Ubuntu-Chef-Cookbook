#
# Cookbook Name:: universe-ubuntu
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'apt::default'

if node['platform_version'] == '14.04'
  apt_repository 'newer golang apt repo' do
    uri 'ppa:ubuntu-lxc/lxd-stable'
  end
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
  notifies :run, 'execute[install_anaconda]', :immediately
end

execute 'install_anaconda' do
  user 'vagrant'
  command 'bash /tmp/Anaconda3-4.2.0-Linux-x86_64.sh -b'
  not_if '[ -x /home/vagrant/anaconda3/bin/conda ]'
end
