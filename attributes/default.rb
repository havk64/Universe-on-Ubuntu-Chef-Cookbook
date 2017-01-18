default['universe']['user']['name'] = 'vagrant'
default['universe']['gpu'] =  false # Change to 'true' to enable gpu processing
user = default['universe']['user']['name']
default['universe']['user']['home'] = automatic['etc']['passwd'][user]['dir']
gpu = node['universe']['gpu'] ? 'gpu' : 'cpu'
default['universe']['tf_binary'] = "https://storage.googleapis.com/tensorflow/linux/#{gpu}/tensorflow-0.11.0-cp35-cp35m-linux_x86_64.whl"
