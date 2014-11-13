# Machete

Machete is the CF buildpack test framework.


# Prerequisites

## ci-tools

Clone [ci-tools](https://github.com/cf-buildpacks/ci-tools) into `~/workspace`.

## Bosh-Lite

The tests expect two Cloud Foundry installations to be present - an online one at 10.244.0.34 and an offline one at 10.245.0.34.

We use [bosh-lite](https://github.com/cloudfoundry/bosh-lite) for the online instance and [bosh-lite-2nd-instance](https://github.com/cf-buildpacks/bosh-lite-2nd-instance) for the offline instance.

See [bosh-lite](https://github.com/cloudfoundry/bosh-lite) or [bosh-lite-2nd-instance](https://github.com/cf-buildpacks/bosh-lite-2nd-instance) for more instructions.


# Usage

1. Navigate to the buildpack that you want to test (e.g., [Ruby Buildpack](https://github.com/cloudfoundry/ruby-buildpack))
1. Update submodules:
```bash
git submodule update --init
```
1. Run buildpack-build with desired mode
```bash
~/workspace/ci-tools/buildpack-build [ online | offline ]
```

`buildpack-build` will create a buildpack in one of two modes and upload it to your local bosh-lite based Cloud Foundry installations:

* online : Dependencies can be fetched from the internet.
* offline : Dependencies, such as ruby, are installed from a cache included in the buildpack.


# Logging

Errors in the Machete library log to STDOUT by default. You can change Machete's default log:

```RUBY
  Machete.logger = Machete::Logger.new("log/integration.log")
```


## Notes

### RVM Version

You may encounter a silent early exit for scripts offline-build and online-build. This is an issue with RVM running
inside a bash script with `set -e`.

Ensure you have the latest stable version of RVM

    $ rvm --version # At least version 1.25.22

