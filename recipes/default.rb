#
# Cookbook Name:: universe_ubuntu
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'universe_ubuntu::essentials'
include_recipe 'universe_ubuntu::tensorflow'
include_recipe 'universe_ubuntu::cuda' if node['universe']['gpu']
include_recipe 'universe_ubuntu::docker'
include_recipe 'universe_ubuntu::openai'

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
