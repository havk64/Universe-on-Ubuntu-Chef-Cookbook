default['universe']['user'] = 'vagrant'
user = default['universe']['user']

default['universe']['home'] = automatic['etc']['passwd'][user]['dir']
