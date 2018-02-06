#!/bin/bash
set -e

if [ x"$1" = x"list" ]; then
  aptly repo show -with-packages local
  exit
fi

if [ ! -e ~/.aptly.conf ]; then
cat > ~/.aptly.conf <<EOF
{
    "architectures": ["amd64"],
    "ppaCodename": "xenial"
}
EOF
fi

if aptly publish list | grep -qF ' ./sid '; then
  aptly publish drop sid
fi

if aptly repo show local >/dev/null; then
  aptly repo drop local
fi

aptly repo create local
aptly repo add local deb/

#aptly mirror show paper-theme >/dev/null || aptly mirror create -filter='paper-icon-theme|paper-cursor-theme' -filter-with-deps=true paper-theme ppa:snwh/pulp
#aptly mirror update paper-theme
#aptly repo remove local 'paper-icon-theme|paper-cursor-theme'
#aptly repo import paper-theme local Name

aptly publish repo -distribution="sid" -skip-contents local
aptly db cleanup
aptly repo show -with-packages local

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
  if [ "$(git status --porcelain | grep -cEv '/(InRelease|Release|Release.gpg)$')" -gt 0 ]; then
    git commit --amend --no-edit
    git reflog expire --expire=now --all
    git gc --prune=now --aggressive
    git push --force
  else
      git reset --hard
  fi
fi
