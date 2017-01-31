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
      end.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
