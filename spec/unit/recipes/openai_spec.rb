#
# Cookbook Name:: universe_ubuntu
# Spec:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'universe_ubuntu::openai' do
  context 'When all attributes are default, on Ubuntu 14.04 platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
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
