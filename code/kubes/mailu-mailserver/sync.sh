#!/bin/sh

sudo helm upgrade --install mailu mailu/mailu --version 1.5.0 -n mailu-mailserver --create-namespace --values values.yaml
