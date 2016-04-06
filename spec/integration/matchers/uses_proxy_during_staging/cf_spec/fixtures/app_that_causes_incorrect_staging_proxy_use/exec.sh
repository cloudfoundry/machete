#!/bin/sh
unset http_proxy
unset https_proxy
curl https://google.com
curl http://soundcloud.com
curl http://spotify.com
sleep 2
