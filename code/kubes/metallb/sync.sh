#!/bin/sh

sudo helm upgrade --install metallb metallb/metallb -n metallb --create-namespace --values values.yaml
