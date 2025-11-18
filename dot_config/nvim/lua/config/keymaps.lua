-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Make gd jump to definition in the current window
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })
