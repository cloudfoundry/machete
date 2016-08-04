App that logs conditionally
===============================

An empty app that uses whatever ruby is on a droplet to hold $PORT open.
In short, it keeps the app marked as running.

This app will be used by a buildpack that will log one line of output by
default. If the $NOISE env var is specified, the buildpack will log 151 lines of
output. This is to test the have_logged matcher and its ability to look through
all the staging logs.
