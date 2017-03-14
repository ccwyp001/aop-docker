#!/bin/bash

os=centos

version=$1
version=${version:-"latest"}

app_component=agent

if [[ ! $version =~ ^[0-9]*\.[0-9]*\.[0-9]*$ ]] && [ "$version" != "latest" ]; then
    echo "Incorrect syntax of the version"
    exit 1
fi

docker build -t aop-$app_component:$os-$version -f Dockerfile .
