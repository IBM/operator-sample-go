#!/bin/bash

inputfile=kustomization.yaml
outputfile=../config/default/kustomization.yaml

echo ${PWD}

#sed -i '/${line}/s/^#//g'
search='#- ../prometheus'
replace='- ../prometheus'

sed "s+$search+$replace+g" ./$inputfile > ./$outputfile