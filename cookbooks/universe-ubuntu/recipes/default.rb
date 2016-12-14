#
# Cookbook Name:: universe-ubuntu
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'apt::default'

package 'install basic apt packages' do
  package_name %w(golang
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
end
