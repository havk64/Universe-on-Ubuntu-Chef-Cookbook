user = default['universe']['user']['name']
home = default['universe']['user']['home']
gpu = node['universe']['gpu'] ? 'gpu' : 'cpu'

default['universe']['user']['name'] = 'vagrant'
default['universe']['user']['home'] = automatic['etc']['passwd'][user]['dir']
default['universe']['conda_prefix'] = "#{home}/anaconda3/envs/universe"
default['universe']['gpu'] =  false # Change to 'true' to enable gpu processing
default['universe']['tf_binary'] = "https://storage.googleapis.com/tensorflow/linux/#{gpu}/tensorflow-0.11.0-cp35-cp35m-linux_x86_64.whl"
default['universe']['conda_env'][:CONDA_DEFAULT_ENV] = 'universe'
default['universe']['conda_env'][:CONDA_PREFIX] = "#{home}/anaconda3/envs/universe"
default['universe']['conda_env'][:PATH] = "#{home}/anaconda3/envs/universe/bin:#{ENV['PATH']}"
