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

    it 'Include openai recipe' do
      expect(chef_run).to include_recipe('universe_ubuntu::openai')
    end

    it 'Create universe_test template' do
      expect(chef_run).to create_template('/home/vagrant/universe_test.py')
        .with(owner: 'vagrant', group: 'vagrant', source: 'universe_test.erb')
    end
  end
end
