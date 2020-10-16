#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

bash $DIR/inst.sh

yes | sudo cp $DIR/conky_bar_laptop /usr/share/conky/conky_bar
