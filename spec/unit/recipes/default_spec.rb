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
        node.automatic['os_version'] = 'specific_kernel_version'
      end.converge(described_recipe)
    end

    let(:dpkg) { chef_run.dpkg_package('cuda-repo-ubuntu1404_8.0.44-1_amd64.deb') }

    let(:add_user) { chef_run.group('docker') }

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'Include apt recipe' do
      expect(chef_run).to include_recipe('apt::default')
    end

    it 'add new golang repository' do
      expect(chef_run).to add_apt_repository('newer golang apt repo')
    end

    it 'edit /etc/X11/Xwrapper.config' do
      expect(chef_run).to run_ruby_block('Allow non root users start the GUI')
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
      expect(chef_run).to run_execute(
        "bash #{Chef::Config[:file_cache_path]}/Anaconda3-4.2.0-Linux-x86_64.sh -b")
        .with(user: 'vagrant')
    end

    it 'creates openai directory' do
      expect(chef_run).to create_directory('/home/vagrant/openai')
    end

    it 'creates conda env file' do
      expect(chef_run).to create_template('/home/vagrant/openai/environment.yml')
        .with(owner: 'vagrant',
              group: 'vagrant')
    end

    it 'creates conda environment' do
      expect(chef_run).to run_execute('/home/vagrant/anaconda3/bin/conda env create -f environment.yml')
        .with(user: 'vagrant', cwd: '/home/vagrant/openai')
    end

    it 'add lines to shell config files' do
      expect(chef_run).to run_ruby_block('Add Anaconda and Universe to bashrc')
    end

    it 'Installs Tensorflow' do
      conda_prefix = '/home/vagrant/anaconda3/envs/universe'
      expect(chef_run).to run_execute(
        "#{conda_prefix}/bin/pip install --ignore-installed --upgrade "\
        'https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.11.0-cp35-cp35m-linux_x86_64.whl')
        .with(
          user: 'vagrant',
          environment: {
            'CONDA_DEFAULT_ENV' => 'universe',
            'CONDA_PREFIX' => conda_prefix,
            'PATH' => "#{conda_prefix}/bin:#{ENV['PATH']}"
          })
    end

    it 'Create Cuda deb install file' do
      expect(chef_run).to create_remote_file(
        "#{Chef::Config[:file_cache_path]}/cuda-repo-ubuntu1404_8.0.44-1_amd64.deb")
        .with(
          source: 'http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_8.0.44-1_amd64.deb',
          checksum: '83c1be62a56c1ac245379f8ffb00168d8aee8ca7168ee0f17fa08ce03bc3881d'
        )
    end

    it 'Add Cuda repo and update pkg list' do
      expect(chef_run).to install_dpkg_package('cuda-repo-ubuntu1404_8.0.44-1_amd64.deb')
      expect(dpkg).to notify('execute[apt-get update]').immediately
    end

    it 'Install Cuda toolkit' do
      expect(chef_run).to install_package('cuda')
    end

    it 'Add Cuda env variables' do
      expect(chef_run).to run_ruby_block('Add Cuda env variables')
    end

    docker_pkgs = ['linux-image-extra-specific_kernel_version',
                   'linux-image-extra-virtual',
                   'docker-engine']

    docker_pkgs.each do |name|
      it "Installs #{name} package" do
        expect(chef_run).to install_package(name)
      end
    end

    it 'Add current user to docker group' do
      expect(chef_run).to modify_group('docker')
    end

    it 'Notifies service docker restart' do
      expect(add_user).to notify('service[docker]').to(:restart).immediately
    end

    it 'Notifies service lightdm' do
      expect(add_user).to notify('service[lightdm]').to(:restart).immediately
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
