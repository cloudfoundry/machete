#!/bin/bash --login

source "$HOME/.rvm/scripts/rvm"
rvm use 1.9.3

scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ~/workspace/cf-release
bundle
./update
rm -f dev_releases/*.yml
bundle exec bosh create release

cd ~/workspace/bosh-lite
vagrant destroy -f
vagrant up --provider vmware_fusion
bundle exec bosh target 192.168.50.4
bundle exec bosh login admin admin
scripts/add-route
wget http://bosh-jenkins-gems-warden.s3.amazonaws.com/stemcells/latest-bosh-stemcell-warden.tgz -O latest-bosh-stemcell-warden.tgz
bundle exec bosh upload stemcell latest-bosh-stemcell-warden.tgz
bundle exec ./scripts/make_manifest_spiff
bundle exec bosh upload release ~/workspace/cf-release/dev_releases/cf-*.yml
sed -i '' -e 's/bosh-warden-boshlite-ubuntu$/bosh-warden-boshlite-ubuntu-lucid-go_agent/g' manifests/cf-manifest.yml
bundle exec bosh deployment manifests/cf-manifest.yml
bundle exec bosh -n deploy

$scripts_dir/online_api
