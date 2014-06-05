#!/bin/bash --login

source "$HOME/.rvm/scripts/rvm"

scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bosh_lite_path=~/workspace/bosh-lite-2nd-instance

cd ~/workspace/cf-release
bundle
./update
rm -f dev_releases/*.yml
bundle exec bosh create release

cd $bosh_lite_path
bundle
vagrant destroy -f
vagrant up --provider vmware_fusion
bundle exec bosh target 192.168.100.4
bundle exec bosh login admin admin
./scripts/prepare-director.sh
./scripts/add-route
wget http://bosh-jenkins-gems-warden.s3.amazonaws.com/stemcells/latest-bosh-stemcell-warden.tgz -O latest-bosh-stemcell-warden.tgz
bundle exec bosh upload stemcell latest-bosh-stemcell-warden.tgz
./scripts/make_manifest_spiff
sed -i '' -e 's/bosh-warden-boshlite-ubuntu$/bosh-warden-boshlite-ubuntu-lucid-go_agent/g' manifests/cf-manifest.yml
bundle exec bosh upload release ~/workspace/cf-release/dev_releases/cf-*.yml
bundle exec bosh deployment manifests/cf-manifest.yml
bundle exec bosh -n deploy

$scripts_dir/add-routes
$scripts_dir/offline_api
$scripts_dir/setup_databases

cd $scripts_dir/..
bundle
VAGRANT_CWD=$bosh_lite_path bundle exec $scripts_dir/enable_bosh_enterprise_firewall.rb
