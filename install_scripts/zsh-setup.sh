sudo apt-get install -y zsh fzf zoxide direnv
chsh -s $(which zsh)
# Start zsh to execute the zshrc file and install zinit
zsh -c "source $HOME/.zshrc"
