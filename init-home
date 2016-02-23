#!/bin/bash
set -e
set -x
cd ~/
git clone --bare git://github.com/azuwis/home.git .git
git config --file=.git/config core.bare false
git config --file=.git/config core.logallrefupdates true
git config --file=.git/config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
git fetch origin
git branch --set-upstream master origin/master
git reset HEAD .
git status
