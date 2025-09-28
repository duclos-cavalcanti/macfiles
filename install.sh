#!/bin/bash

# installing zsh plugin
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# installing rust
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
