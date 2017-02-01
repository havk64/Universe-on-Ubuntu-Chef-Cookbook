#
# Cookbook Name:: Universe-on-Ubuntu-Chef-Recipe
# Recipe:: cuda
#
# Copyright (c) 2017 The Authors, All Rights Reserved.
include_recipe 'apt::default'

remote_file "#{Chef::Config[:file_cache_path]}/#{node['universe']['cuda']['debfile']}" do
  source node['universe']['cuda']['source']
  checksum node['universe']['cuda']['checksum']
end

dpkg_package "#{node['universe']['cuda']['debfile']}" do
  source "#{Chef::Config[:file_cache_path]}/#{node['universe']['cuda']['debfile']}"
  notifies :run, 'execute[apt-get update]', :immediately
end

package 'cuda'

ruby_block 'Add Cuda env variables' do
  block do
    file = Chef::Util::FileEdit.new "#{home}/.bashrc"
    file.insert_line_if_no_match(/^export LD_LIBRARY_PATH/,
    'export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64"')
    file.insert_line_if_no_match(/^export CUDA_HOME/, 'export CUDA_HOME=/usr/local/cuda')
    file.write_file
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/#{node['universe']['cudnn']['file']}" do
  owner 'root'
  group 'root'
  source node['universe']['cudnn']['source']
  checksum node['universe']['cudnn']['checksum']
end

execute 'Install CuDNN' do
  cwd "#{Chef::Config[:file_cache_path]}"
  command "/bin/tar xzf #{node['universe']['cudnn']['file']} -C /usr/local"
end

execute 'Map shared library' do
  command '/sbin/ldconfig'
end
