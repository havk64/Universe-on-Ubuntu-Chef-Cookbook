default['universe']['user'] = 'vagrant'
default['universe']['gpu'] =  false # Change to 'true' to enable gpu processing
user = default['universe']['user']

default['universe']['home'] = automatic['etc']['passwd'][user]['dir']
