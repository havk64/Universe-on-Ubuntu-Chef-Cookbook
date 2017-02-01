#
# Cookbook Name:: universe_ubuntu
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'universe_ubuntu::essentials'
include_recipe 'universe_ubuntu::tensorflow'
include_recipe 'universe_ubuntu::cuda' if node['universe']['gpu']
include_recipe 'universe_ubuntu::docker'

user = node['universe']['user']['name']
home = node['universe']['user']['home']
conda_env = node['universe']['conda_env']
conda_prefix = conda_env['CONDA_PREFIX']

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
