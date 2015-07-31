# Machete

Machete is the CF buildpack test framework.


# Prerequisites

## Cloud Foundry

The tests require a running instance of Cloud Foundry. By default, it will try to find an instance at the local IP 10.244.0.34. You can specify an alternative Cloud Foundry instance with the `--host` argument.

We run our tests with a local bosh-lite deployment. See [the github repo](https://github.com/cloudfoundry/bosh-lite) for more instructions.

These tests assume an org named `pivotal` and a space named `integration` exist.
Use these commands to create them: 

```
cf create-org pivotal
cf create-space integration
```

# Usage

1. Navigate to the buildpack that you want to test (e.g., [Ruby Buildpack](https://github.com/cloudfoundry/ruby-buildpack))
1. Update submodules:
```
git  submodule update --init
```
1. From your buildpack's directory, run the `buildpack-build` script.
```bash
bundle exec buildpack-build
```

Buildpack Modes:

* uncached: Buildpack dependencies will be fetched from the internet when staging an app.
* cached : Buildpack dependencies will be downloaded and bundled with the buildpack before uploading it to Cloud Foundry.

If you only want to run your tests with one mode, you can use the `bundle exec buildpack-build [ cached | uncached ]` script instead.


# Logging

Errors in the Machete library log to STDOUT by default. You can change Machete's default log:

```RUBY
  Machete.logger = Machete::Logger.new("log/integration.log")
```


## Notes

### RVM Version

You may encounter a silent early exit for scripts cached-build and uncached-build. This is an issue with RVM running
inside a bash script with `set -e`.

Ensure you have the latest stable version of RVM

    $ rvm --version # At least version 1.25.22

