#
# Cookbook Name:: universe_ubuntu
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'universe_ubuntu::default' do
  context 'When all attributes are default, on an Ubuntu' do
    before do
      stub_command('[ -x /home/vagrant/anaconda3/bin/conda ]').and_return(0)
      stub_command('[ -e /home/vagrant/anaconda3/envs/universe ]').and_return(0)
      stub_command('[ -x /home/vagrant/anaconda3/envs/universe/bin/tensorboard ]').and_return(0)
    end

    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.override['universe']['user'] = 'vagrant'
        node.override['universe']['home'] = '/home/vagrant'
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
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
              swig)

    pkgs.each do |name|
      it "install #{name} package" do
        expect(chef_run).to install_package name
      end
    end

    it 'creates remote_file anaconda if missing' do
      user = 'vagrant'
      expect(chef_run).to create_remote_file_if_missing(
        "#{Chef::Config[:file_cache_path]}/Anaconda3-4.2.0-Linux-x86_64.sh")
        .with(
          owner: user,
          group: user,
          mode: '0755',
          checksum: '73b51715a12b6382dd4df3dd1905b531bd6792d4aa7273b2377a0436d45f0e78'
        )
    end

    it 'installs anaconda' do
      expect(chef_run).to_not run_execute("bash #{Chef::Config[:file_cache_path]}/Anaconda3-4.2.0-Linux-x86_64.sh -b")
        .with(user: 'vagrant')
    end

    it 'creates conda env file' do
      expect(chef_run).to create_cookbook_file('/home/vagrant/environment.yml')
    end
  end
end
