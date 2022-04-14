#!/bin/bash

curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash

echo '
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
' >> ~/.bashrc

. ~/.bashrc

