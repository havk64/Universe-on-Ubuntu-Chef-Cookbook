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
