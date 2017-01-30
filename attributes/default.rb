default['universe']['user']['name'] = 'vagrant'
default['universe']['user']['home'] = '/home/vagrant'
default['universe']['conda_env']['CONDA_DEFAULT_ENV'] = 'universe'
default['universe']['conda_env']['CONDA_PREFIX'] = '/home/vagrant/anaconda3/envs/universe'
default['universe']['conda_env']['PATH'] = "/home/vagrant/anaconda3/envs/universe/bin:#{ENV['PATH']}"
default['universe']['gpu'] =  false # Change to 'true' to enable gpu processing
gpu = node['universe']['gpu'] ? 'gpu' : 'cpu'
default['universe']['tf_binary'] = "https://storage.googleapis.com/tensorflow/linux/#{gpu}/tensorflow-0.11.0-cp35-cp35m-linux_x86_64.whl"

case node['platform_version']
when '14.04'
  prefix = 'ubuntu1404'
  default['universe']['cuda']['debfile'] = "cuda-repo-#{prefix}_8.0.44-1_amd64.deb"
  default['universe']['cuda']['source'] = "http://developer.download.nvidia.com/compute/cuda/repos/#{prefix}/x86_64/cuda-repo-#{prefix}_8.0.44-1_amd64.deb"
  default['universe']['cuda']['checksum'] = '83c1be62a56c1ac245379f8ffb00168d8aee8ca7168ee0f17fa08ce03bc3881d' # md5: 'aac9771df4b0e11879434b0439aed227'
when '16.04'
  prefix = 'ubuntu1604'
  default['universe']['cuda']['debfile'] = "cuda-repo-#{prefix}_8.0.44-1_amd64.deb"
  default['universe']['cuda']['source'] = "http://developer.download.nvidia.com/compute/cuda/repos/#{prefix}/x86_64/cuda-repo-#{prefix}_8.0.44-1_amd64.deb"
  default['universe']['cuda']['checksum'] = 'e265b296f3d4d98698782dfb9257c4e9ae44aae7068e060fba487e54af99fae2' # md5: '16b0946a3c99ca692c817fb7df57520c'
end
