default['universe']['user']['name'] = 'vagrant'
default['universe']['gpu'] =  false # Change to 'true' to enable gpu processing
user = default['universe']['user']['name']

default['universe']['user']['home'] = automatic['etc']['passwd'][user]['dir']
