#
# Cookbook Name:: universe_ubuntu
# Spec:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'universe_ubuntu::tensorflow' do
  context 'When all attributes are default, on Ubuntu 14.04 platform' do
    before do
      stub_command('[ -x /home/vagrant/anaconda3/bin/conda ]').and_return(false)
      stub_command('[ -e /home/vagrant/anaconda3/envs/universe/bin/wheel ]').and_return(false)
      stub_command('[ -x /home/vagrant/anaconda3/envs/universe/bin/tensorboard ]').and_return(false)
    end

    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.override['universe']['gpu'] = true
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
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
              group: 'vagrant',
              source: 'environment.erb')
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
  end
end
