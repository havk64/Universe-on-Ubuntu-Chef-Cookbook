#
# Cookbook Name:: universe_ubuntu
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'universe_ubuntu::default' do
  context 'When all attributes are default, on an Ubuntu' do
    before do
      stub_command("[ -x /home/vagrant/anaconda3/bin/conda ]").and_return(0)
    end

    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.override['etc']['passwd']['vagrant']['dir'] = '/home/vagrant'
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
  end
end
