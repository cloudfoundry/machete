Online app for correct proxy usage during staging
===============================

An empty app that uses whatever ruby is on a droplet to hold $PORT open.
In short, it keeps the app marked as running.

This app's exec.sh will utilize the http_proxy env var in making a few sample requests.
This simulates a buildpack that correctly uses proxies during staging.
