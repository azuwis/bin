#!/bin/bash
set -eu

if [ ! -e ~/.aptly.conf ]; then
cat > ~/.aptly.conf <<EOF
{
    "architectures": ["amd64"],
    "ppaCodename": "xenial"
}
EOF
fi

aptly repo show local >/dev/null || aptly repo create local
aptly repo add local deb/

aptly mirror show paper-theme >/dev/null || aptly mirror create -filter=paper-icon-theme -filter-with-deps=true paper-theme ppa:snwh/pulp
aptly mirror update paper-theme
aptly repo import paper-theme local Name

if aptly publish list | grep -qF ' ./sid '; then
  aptly publish update sid
else
  aptly publish repo -distribution="sid" -skip-contents local
fi

cd ~/.aptly/public
if [ ! -e .git ]; then
  git init
  git checkout -b gh-pages
  git add .
  git commit -m 'Update'
  git remote add origin https://github.com/azuwis/debian.git
  git push -u origin gh-pages
else
  git add .
  if [ "$(git status --porcelain | wc -l)" -gt 0 ]; then
    git commit --amend --no-edit
    git push --force
  fi
fi

# aptly repo show -with-packages local
