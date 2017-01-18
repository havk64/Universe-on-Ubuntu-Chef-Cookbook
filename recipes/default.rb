#
# Cookbook Name:: universe_ubuntu
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'apt::default'

user = node['universe']['user']['name']
home = node['universe']['user']['home']
gpu = node['universe']['gpu'] ? 'gpu' : 'cpu'
tf_binary = "https://storage.googleapis.com/tensorflow/linux/#{gpu}/tensorflow-0.11.0-cp35-cp35m-linux_x86_64.whl"
conda_prefix = "#{home}/anaconda3/envs/universe"
path = {
  PATH:               "#{conda_prefix}/bin:#{ENV['PATH']}",
  CONDA_PREFIX:       conda_prefix,
  CONDA_DEFAULT_ENV:  'universe'
}

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

cookbook_file "#{home}/environment.yml" do
  source 'environment.yml'
end

execute 'Create a conda environment' do
  user user
  cwd home
  command "#{home}/anaconda3/bin/conda env create -f environment.yml"
  not_if "[ -e #{conda_prefix} ]"
end

ruby_block 'Add Anaconda and Universe to bashrc' do
  block do
    file = Chef::Util::FileEdit.new "#{home}/.bashrc"
    file.insert_line_if_no_match(%r{#{home}/anaconda3/bin:\$PATH"$},
    "export PATH=\"#{home}/anaconda3/bin:$PATH\"")
    file.insert_line_if_no_match(/source activate universe/,
    'source activate universe')
    file.write_file
  end
end

execute 'Install Tensorflow' do
  user user
  environment path
  command "#{conda_prefix}/bin/pip install --ignore-installed --upgrade #{tf_binary}"
  not_if "[ -x #{conda_prefix}/bin/tensorboard ]"
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

service 'docker' do
  action :nothing
end

group 'docker' do
  action :modify
  append true
  members user
  notifies :restart, 'service[docker]', :immediately
end

git "#{home}/gym" do
  repository 'https://github.com/openai/gym.git'
  revision 'master'
  action :sync
end

git "#{home}/universe" do
  repository 'https://github.com/openai/universe.git'
  revision 'master'
  action :sync
end

git "#{home}/universe-starter-agent" do
  user user
  repository 'https://github.com/openai/universe-starter-agent.git'
  revision 'master'
  action :sync
end

execute 'Install gym modules' do
  user user
  environment path
  cwd "#{home}/gym"
  command "#{conda_prefix}/bin/pip install -e '.[all]'"
end

execute 'Install Universe modules' do
  user user
  environment path
  cwd "#{home}/universe"
  command "#{conda_prefix}/bin/pip install -e ."
end
