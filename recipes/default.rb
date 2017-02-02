#
# Cookbook Name:: universe_ubuntu
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'universe_ubuntu::essentials'
include_recipe 'universe_ubuntu::tensorflow'
include_recipe 'universe_ubuntu::cuda' if node['universe']['gpu']
include_recipe 'universe_ubuntu::docker'
include_recipe 'universe_ubuntu::openai'

template "#{node['universe']['user']['home']}/universe_test.py" do
  owner node['universe']['user']['name']
  group node['universe']['user']['name']
  source 'universe_test.erb'
end
