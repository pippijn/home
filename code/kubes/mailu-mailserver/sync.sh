#!/bin/sh

sudo helm upgrade --install mailu mailu/mailu --version 0.3.5 -n mailu-mailserver --create-namespace --values values.yaml
