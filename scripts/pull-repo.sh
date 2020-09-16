#!/bin/bash

cd "$HOME"/mailfilter || exit
git pull
chmod 600 filter/*.maildrop
chmod +x scripts/*.sh
dos2unix filter/*
