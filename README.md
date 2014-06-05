# Machete

Machete is the CF buildpack test framework.

# Options

Online and offline mode (default: online):

    BUILDPACK_MODE=[online|offline]

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

