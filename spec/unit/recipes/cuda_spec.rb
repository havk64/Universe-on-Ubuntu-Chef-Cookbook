#
# Cookbook Name:: Universe-on-Ubuntu-Chef-Recipe
# Spec:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'universe_ubuntu::cuda' do
  context 'When all attributes are default, on Ubuntu 14.04' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.override['universe']['cuda']['debfile'] = "cuda-repo-ubuntu1404_8.0.44-1_amd64.deb"
        node.override['universe']['cuda']['source'] = "http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_8.0.44-1_amd64.deb"
        node.override['universe']['cuda']['checksum'] = '83c1be62a56c1ac245379f8ffb00168d8aee8ca7168ee0f17fa08ce03bc3881d'
      end.converge(described_recipe)
    end

    let(:dpkg) { chef_run.dpkg_package('cuda-repo-ubuntu1404_8.0.44-1_amd64.deb') }

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
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
  end
end
