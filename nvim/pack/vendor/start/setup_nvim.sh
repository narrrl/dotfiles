#!/bin/bash

rm -rf ~/.config/nvim 
cp -r nvim ~/.config/
git clone https://github.com/neovim/nvim-lspconfig ~/.config/nvim/pack/vendor/start/nvim-lspconfig
git clone https://github.com/echasnovski/mini.nvim ~/.config/nvim/pack/vendor/start/mini.nvim
