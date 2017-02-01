#
# Cookbook Name:: universe_ubuntu
# Spec:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'universe_ubuntu::docker' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.automatic['os_version'] = 'specific_kernel_version'
      end.converge(described_recipe)
    end

    let(:add_user) { chef_run.group('docker') }

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'Include apt recipe' do
      expect(chef_run).to include_recipe('apt::default')
    end

    it 'add docker repository' do
      expect(chef_run).to add_apt_repository('docker')
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
  end
end
