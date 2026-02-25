return {
  {
    "vimpostor/vim-tpipeline",
    cond = function()
      return vim.env.TMUX ~= nil
    end,
    init = function()
      -- Restore tmux statusline settings when leaving Neovim.
      vim.g.tpipeline_restore = 1
      -- Avoid stacked Neovim + tmux statuslines.
      vim.g.tpipeline_clearstl = 1
    end,
  },
}
