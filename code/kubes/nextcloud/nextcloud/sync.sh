#!/bin/sh

sudo helm upgrade --install redis bitnami/redis -n nextcloud --create-namespace --values redis-values.yaml
