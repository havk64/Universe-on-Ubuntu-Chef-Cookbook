# Universe on Ubuntu Chef Cookbook

(In Development)

The Universe on Ubuntu cookbook creates a virtual machine with Ubuntu 16.04LTS or 14.04LTS as operating system and configures all environment needed to make it possible to use [OpenAI Universe](https://universe.openai.com/) as a software platform to measure and train Artificial Intelligence on an extremely wide range of real-time, complex and heterogeneous environments.

More info about Universe: https://openai.com/blog/universe/

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
