# # encoding: utf-8

# Inspec test for recipe universe-ubuntu::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

packages = %w(golang
              libjpeg-turbo8-dev
              make
              tmux
              htop
              chromium-browser
              git
              cmake
              zlib1g-dev
              libjpeg-dev
              xvfb
              libav-tools
              xorg-dev
              python-opengl
              libboost-all-dev
              libsdl2-dev
              swig)

packages.each do |item|
  describe package item do
    it { should be_installed }
  end
end

describe file '/tmp/kitchen/cache/Anaconda3-4.2.0-Linux-x86_64.sh' do
  it { should exist }
end
