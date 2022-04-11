#!/bin/bash

inputfile=kustomization.yaml
outputfile=../config/default/kustomization.yaml

search='#- ../prometheus'
replace='- ../prometheus'

sed "s+$search+$replace+g" ./$inputfile > ./$outputfile