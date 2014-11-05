#!/bin/bash --login

./scripts/online_api
./scripts/offline_api
./scripts/setup_databases

bundle
VAGRANT_CWD=$HOME/workspace/bosh-lite-2nd-instance bundle exec ./scripts/enable_bosh_enterprise_firewall.rb
