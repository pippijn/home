#!/bin/sh

sudo helm upgrade --install mailu mailu/mailu -n mailu-mailserver --create-namespace --values mailu-values.yaml
