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
        node.override['universe']['gpu'] = true
        node.automatic['os_version'] = 'specific_kernel_version'
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'add new golang repository' do
      expect(chef_run).to add_apt_repository('lxd-stable')
    end

    it 'add docker repository' do
      expect(chef_run).to add_apt_repository('docker')
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

    it 'creates conda environment' do
      expect(chef_run).to_not run_execute('conda env create -f environment.yml')
        .with(user: 'vagrant', cwd: '/home/vagrant')
    end

    it 'Installs Tensorflow' do
      conda_prefix = '/home/vagrant/anaconda3/envs/universe'
      expect(chef_run).to_not run_execute("#{conda_prefix}/bin/pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.11.0-cp35-cp35m-linux_x86_64.whl")
        .with(
          user: 'vagrant',
          environment: {
            PATH: "#{conda_prefix}/bin:#{ENV['PATH']}",
            CONDA_PREFIX: conda_prefix,
            CONDA_DEFAULT_ENV: 'universe'
          })
    end

    docker_pkgs = ['linux-image-extra-specific_kernel_version',
                   'linux-image-extra-virtual',
                   'docker-engine']

    docker_pkgs.each do |name|
      it "Installs #{name} package" do
        expect(chef_run).to install_package(name)
      end
    end

    it 'Clone gym repo' do
      expect(chef_run).to sync_git("/home/vagrant/gym")
    end

    it 'Clone universe repo' do
      expect(chef_run).to sync_git("/home/vagrant/universe")
    end

    it 'Clone starter agent repo' do
      expect(chef_run).to sync_git("/home/vagrant/universe-starter-agent")
    end
  end
end
