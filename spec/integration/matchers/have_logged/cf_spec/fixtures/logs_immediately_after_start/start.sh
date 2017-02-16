#!/bin/bash

echo "Immediate output after app start"

ruby -run -e httpd . -p $PORT
