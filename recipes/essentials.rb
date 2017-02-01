#
# Cookbook Name:: universe_ubuntu
# Recipe:: essentials
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

include_recipe 'apt::default'

apt_repository 'newer golang apt repo' do
  uri 'ppa:ubuntu-lxc/lxd-stable'
  only_if { node['platform_version'] == '14.04' }
end

ruby_block 'Allow non root users start the GUI' do
  block do
    file = Chef::Util::FileEdit.new '/etc/X11/Xwrapper.config'
    file.search_file_replace_line(/^allowed_users=console/,
    'allowed_users=anybody')
    file.write_file
  end
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
              swig
              tilda
              terminator)

packages.each { |item| package item }
