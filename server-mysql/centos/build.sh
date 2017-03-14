#!/bin/bash

os=centos

version=$1
version=${version:-"latest"}

app_component=server
app_database=mysql

if [[ ! $version =~ ^[0-9]*\.[0-9]*\.[0-9]*$ ]] && [ "$version" != "latest" ]; then
    echo "Incorrect syntax of the version"
    exit 1
fi

docker build -t aop-$app_component-$app_database:$os-$version -f Dockerfile .
