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

default['universe']['cudnn']['file'] = 'cudnn-8.0-linux-x64-v5.1.tgz'
default['universe']['cudnn']['source'] = 'http://developer.download.nvidia.com/compute/redist/cudnn/v5.1/cudnn-8.0-linux-x64-v5.1.tgz'
default['universe']['cudnn']['checksum'] = 'c10719b36f2dd6e9ddc63e3189affaa1a94d7d027e63b71c3f64d449ab0645ce'
