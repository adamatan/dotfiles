#!/bin/bash

cd files && find . -type f | cut -c 3- | xargs -I % -n 1 ln -f -s ${PWD}/% ${HOME}/.%

