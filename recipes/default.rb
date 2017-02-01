#
# Cookbook Name:: universe_ubuntu
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'apt::default'
include_recipe 'universe_ubuntu::essentials'

user = node['universe']['user']['name']
home = node['universe']['user']['home']
conda_env = node['universe']['conda_env']
conda_prefix = conda_env['CONDA_PREFIX']
tf_binary = node['universe']['tf_binary']

execute 'Customize the Unity Launcher favorite apps' do
  command 'dbus-launch gsettings set com.canonical.Unity.Launcher favorites '\
    "\"['application://tilda.desktop', 'application://terminator.desktop', "\
    "'application://debian-xterm.desktop', 'application://remmina.desktop', "\
    "'application://chromium-browser.desktop', 'application://firefox.desktop', "\
    "'application://org.gnome.Nautilus.desktop', 'application://org.gnome.Software.desktop', "\
    "'application://unity-control-center.desktop', 'unity://running-apps', "\
    "'unity://expo-icon', 'unity://devices']\""
end

execute 'Set default terminal emulator' do
  command 'dbus-launch gsettings set org.gnome.desktop.default-applications.terminal '\
    "exec '/usr/bin/tilda'"
end

remote_file "#{Chef::Config[:file_cache_path]}/Anaconda3-4.2.0-Linux-x86_64.sh" do
  owner user
  group user
  mode '0755'
  source 'https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh'
  checksum '73b51715a12b6382dd4df3dd1905b531bd6792d4aa7273b2377a0436d45f0e78'
  action :create_if_missing
  not_if "[ -x #{home}/anaconda3/bin/conda ]"
end

execute 'install_anaconda' do
  user user
  command "bash #{Chef::Config[:file_cache_path]}/Anaconda3-4.2.0-Linux-x86_64.sh -b"
  not_if "[ -x #{home}/anaconda3/bin/conda ]"
end

directory "#{home}/openai" do
  owner user
  group user
  mode '0755'
end

template "#{home}/openai/environment.yml" do
  owner user
  group user
  source 'environment.erb'
end

execute 'Create a conda environment' do
  user user
  cwd "#{home}/openai"
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
  environment conda_env
  command "#{conda_prefix}/bin/pip install --ignore-installed --upgrade #{tf_binary}"
  not_if "[ -x #{conda_prefix}/bin/tensorboard ]"
end

include_recipe 'universe_ubuntu::cuda' if node['universe']['gpu']

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
  members user
  notifies :restart, 'service[docker]', :immediately
  notifies :restart, 'service[lightdm]', :immediately
end

git "#{home}/openai/gym" do
  user user
  repository 'https://github.com/openai/gym.git'
  revision 'master'
  action :sync
end

git "#{home}/openai/universe" do
  user user
  repository 'https://github.com/openai/universe.git'
  revision 'master'
  action :sync
end

git "#{home}/openai/universe-starter-agent" do
  user user
  repository 'https://github.com/openai/universe-starter-agent.git'
  revision 'master'
  action :sync
end

execute 'Install gym modules' do
  user user
  environment conda_env
  cwd "#{home}/openai/gym"
  command "#{conda_prefix}/bin/pip install -e '.[all]'"
end

execute 'Install Universe modules' do
  user user
  environment conda_env
  cwd "#{home}/openai/universe"
  command "#{conda_prefix}/bin/pip install -e ."
end
