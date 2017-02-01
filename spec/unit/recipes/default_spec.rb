#
# Cookbook Name:: universe_ubuntu
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'universe_ubuntu::default' do
  context 'When all attributes are default, on an Ubuntu 14.04' do
    before do
      stub_command('[ -x /home/vagrant/anaconda3/bin/conda ]').and_return(false)
      stub_command('[ -e /home/vagrant/anaconda3/envs/universe ]').and_return(false)
      stub_command('[ -x /home/vagrant/anaconda3/envs/universe/bin/tensorboard ]').and_return(false)
    end

    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.override['universe']['user']['name'] = 'vagrant'
        node.override['universe']['user']['home'] = '/home/vagrant'
        node.override['universe']['conda_env']['CONDA_PREFIX'] = '/home/vagrant/anaconda3/envs/universe'
        node.override['universe']['conda_env']['PATH'] = "/home/vagrant/anaconda3/envs/universe/bin:#{ENV['PATH']}"
        node.override['universe']['gpu'] = true
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'Include essentials recipe' do
      expect(chef_run).to include_recipe('universe_ubuntu::essentials')
    end

    it 'Include tensorflow recipe' do
      expect(chef_run).to include_recipe('universe_ubuntu::tensorflow')
    end

    it 'include Cuda recipe' do
      expect(chef_run).to include_recipe('universe_ubuntu::cuda')
    end

    it 'Include docker recipe' do
      expect(chef_run).to include_recipe('universe_ubuntu::docker')
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

    it 'Clone gym repo' do
      expect(chef_run).to sync_git('/home/vagrant/openai/gym').with(user: 'vagrant')
    end

    it 'Clone universe repo' do
      expect(chef_run).to sync_git('/home/vagrant/openai/universe').with(user: 'vagrant')
    end

    it 'Clone starter agent repo' do
      expect(chef_run).to sync_git('/home/vagrant/openai/universe-starter-agent').with(user: 'vagrant')
    end

    it 'Install Gym modules' do
      conda_prefix = '/home/vagrant/anaconda3/envs/universe'
      expect(chef_run).to run_execute("#{conda_prefix}/bin/pip install -e '.[all]'")
        .with(
          user: 'vagrant',
          cwd: '/home/vagrant/openai/gym',
          environment: {
            'CONDA_DEFAULT_ENV' => 'universe',
            'CONDA_PREFIX' => conda_prefix,
            'PATH' => "#{conda_prefix}/bin:#{ENV['PATH']}"
          })
    end

    it 'Install Universe modules' do
      conda_prefix = '/home/vagrant/anaconda3/envs/universe'
      expect(chef_run).to run_execute("#{conda_prefix}/bin/pip install -e .")
        .with(
          user: 'vagrant',
          cwd: '/home/vagrant/openai/universe',
          environment: {
            'CONDA_DEFAULT_ENV' => 'universe',
            'CONDA_PREFIX' => conda_prefix,
            'PATH' => "#{conda_prefix}/bin:#{ENV['PATH']}"
          })
    end
  end
end
