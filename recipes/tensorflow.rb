#
# Cookbook Name:: universe_ubuntu
# Recipe:: tensorflow
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

user = node['universe']['user']['name']
home = node['universe']['user']['home']
conda_env = node['universe']['conda_env']
conda_prefix = conda_env['CONDA_PREFIX']
tf_binary = node['universe']['tf_binary']

remote_file "#{Chef::Config[:file_cache_path]}/Anaconda3-4.2.0-Linux-x86_64.sh" do
  owner user
  group user
  mode '0755'
  source 'https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh'
  checksum '73b51715a12b6382dd4df3dd1905b531bd6792d4aa7273b2377a0436d45f0e78'
  action :create_if_missing
  not_if "[ -x #{home}/anaconda3/bin/conda ]"
end

execute 'install_anaconda' do
  user user
  command "bash #{Chef::Config[:file_cache_path]}/Anaconda3-4.2.0-Linux-x86_64.sh -b"
  not_if "[ -x #{home}/anaconda3/bin/conda ]"
end

directory "#{home}/openai" do
  owner user
  group user
  mode '0755'
end

template "#{home}/openai/environment.yml" do
  owner user
  group user
  source 'environment.erb'
end

execute 'Create a conda environment' do
  user user
  cwd "#{home}/openai"
  command "#{home}/anaconda3/bin/conda env create -f environment.yml"
  not_if "[ -e #{conda_prefix} ]"
end

ruby_block 'Add Anaconda and Universe to bashrc' do
  block do
    file = Chef::Util::FileEdit.new "#{home}/.bashrc"
    file.insert_line_if_no_match(%r{#{home}/anaconda3/bin:\$PATH"$},
    "export PATH=\"#{home}/anaconda3/bin:$PATH\"")
    file.insert_line_if_no_match(/source activate universe/,
    'source activate universe')
    file.write_file
  end
end

execute 'Install Tensorflow' do
  user user
  environment conda_env
  command "#{conda_prefix}/bin/pip install --ignore-installed --upgrade #{tf_binary}"
  not_if "[ -x #{conda_prefix}/bin/tensorboard ]"
end
