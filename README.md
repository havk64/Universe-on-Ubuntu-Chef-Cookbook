# Universe on Ubuntu Chef Cookbook

(In Development)

The Universe on Ubuntu cookbook creates a virtual machine with Ubuntu 16.04LTS or 14.04LTS as operating system and configures all environment needed to make it possible to use [OpenAI Universe](https://universe.openai.com/) as a software platform to measure and train Artificial Intelligence on an extremely wide range of real-time, complex and heterogeneous environments.

More info about Universe: https://openai.com/blog/universe/

## Attributes

    default['universe']['gpu'] = false

The **GPU** attribute is set to `false` by default enabling only **CPU** processing.  
In order to enable **GPU** processing you should change the **GPU** attribute to `true`.  
When GPU attribute is enabled the recipe installs a different version of TensorFlow plus CUDA
and CuDNN libraries.  
> *TensorFlow GPU support requires having a GPU card with NVidia
Compute Capability (>= 3.0).
More info here: [CUDA GPUs](https://developer.nvidia.com/cuda-gpus)*

## Environment

The following packages are automatically installed:

- Anaconda (python 3.5)
- Numpy
- Scipy
- Gym and its modules
- Universe and its modules
- Tensorflow 0.11
- Theano
- Keras
- OpenCV
- Docker
- Golang
- Cuda 8.0 + CuDNN 5.1 (if you choose to enable GPU processing)

## Requirements

### Platforms
- Ubuntu 14.04
- Ubuntu 16.04

### Cookbooks
The following cookbooks are direct dependencies:
- apt '5.0'
- compat_resource

### Chef

- Chef 12.1+

## Authors
- Author:: Alexandro de Oliveira ([alexandro.oliveira@holbertonschool.com](mailto:alexandro.oliveira@holbertonschool.com))
