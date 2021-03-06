#
# Cookbook Name:: universe_ubuntu
# Spec:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'universe_ubuntu::essentials' do
  context 'When all attributes are default, on Ubuntu 14.04 platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'Include apt recipe' do
      expect(chef_run).to include_recipe('apt::default')
    end

    it 'add golang latest repo' do
      expect(chef_run).to add_apt_repository('add golang latest repo')
    end

    it 'edit /etc/X11/Xwrapper.config' do
      expect(chef_run).to run_ruby_block('Allow non root users start the GUI')
    end

    pkgs = %w(golang
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

    pkgs.each do |name|
      it "install #{name} package" do
        expect(chef_run).to install_package name
      end
    end
  end

  context 'When all attributes are default, on Ubuntu 16.04 platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'Include apt recipe' do
      expect(chef_run).to include_recipe('apt::default')
    end

    it 'NOT add new golang repository' do
      expect(chef_run).to_not add_apt_repository('newer golang apt repo')
    end

    it 'NOT edit /etc/X11/Xwrapper.config' do
      expect(chef_run).to_not run_ruby_block('Allow non root users start the GUI')
    end

    pkgs = %w(golang
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

    pkgs.each do |name|
      it "install #{name} package" do
        expect(chef_run).to install_package name
      end
    end

    it 'customize unity launcher favorite apps' do
      expect(chef_run).to run_execute(
        'dbus-launch gsettings set com.canonical.Unity.Launcher favorites '\
        "\"['application://tilda.desktop', 'application://terminator.desktop', "\
        "'application://debian-xterm.desktop', 'application://remmina.desktop', "\
        "'application://chromium-browser.desktop', 'application://firefox.desktop', "\
        "'application://org.gnome.Nautilus.desktop', 'application://org.gnome.Software.desktop', "\
        "'application://unity-control-center.desktop', 'unity://running-apps', 'unity://expo-icon', "\
        "'unity://devices']\"")
    end

    it 'set the default terminal emulator' do
      expect(chef_run).to run_execute(
        'dbus-launch gsettings set org.gnome.desktop.default-applications.terminal '\
        "exec '/usr/bin/tilda'")
    end
  end
end
