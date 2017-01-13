name 'universe_ubuntu'
maintainer 'Alexandro de Oliveira'
maintainer_email 'alexandro.oliveira@holbertonschool.com'
license 'all_rights'
description 'Installs/Configures Universe on an Ubuntu Vagrant instance'
long_description 'Installs/Configures Universe on an Ubuntu Vagrant instance'
version '0.1.0'

# If you upload to Supermarket you should set this so your cookbook
# gets a `View Issues` link
# issues_url 'https://github.com/<insert_org_here>/universe_ubuntu/issues' if respond_to?(:issues_url)

# If you upload to Supermarket you should set this so your cookbook
# gets a `View Source` link
# source_url 'https://github.com/<insert_org_here>/universe_ubuntu' if respond_to?(:source_url)

depends 'apt', '~> 5.0'
