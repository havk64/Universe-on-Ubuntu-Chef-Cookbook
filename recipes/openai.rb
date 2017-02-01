#
# Cookbook Name:: universe_ubuntu
# Recipe:: openai
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

user = node['universe']['user']['name']
home = node['universe']['user']['home']
conda_env = node['universe']['conda_env']
conda_prefix = conda_env['CONDA_PREFIX']

git "#{home}/openai/gym" do
  user user
  repository 'https://github.com/openai/gym.git'
  revision 'master'
  action :sync
end

git "#{home}/openai/universe" do
  user user
  repository 'https://github.com/openai/universe.git'
  revision 'master'
  action :sync
end

git "#{home}/openai/universe-starter-agent" do
  user user
  repository 'https://github.com/openai/universe-starter-agent.git'
  revision 'master'
  action :sync
end

execute 'Install gym modules' do
  user user
  environment conda_env
  cwd "#{home}/openai/gym"
  command "#{conda_prefix}/bin/pip install -e '.[all]'"
end

execute 'Install Universe modules' do
  user user
  environment conda_env
  cwd "#{home}/openai/universe"
  command "#{conda_prefix}/bin/pip install -e ."
end
