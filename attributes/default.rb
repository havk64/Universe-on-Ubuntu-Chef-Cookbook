default['universe']['user']['name'] = 'vagrant'
default['universe']['user']['home'] = '/home/vagrant'
default['universe']['conda_env'][:CONDA_DEFAULT_ENV] = 'universe'
default['universe']['conda_env'][:CONDA_PREFIX] = "/home/vagrant/anaconda3/envs/universe"
default['universe']['conda_env'][:PATH] = "/home/vagrant/anaconda3/envs/universe/bin:#{ENV['PATH']}"
default['universe']['gpu'] =  false # Change to 'true' to enable gpu processing
gpu = node['universe']['gpu'] ? 'gpu' : 'cpu'
default['universe']['tf_binary'] = "https://storage.googleapis.com/tensorflow/linux/#{gpu}/tensorflow-0.11.0-cp35-cp35m-linux_x86_64.whl"
