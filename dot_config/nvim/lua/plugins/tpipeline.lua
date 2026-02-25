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
    config = function()
      -- In tmux, hide Neovim's own statusline line and let tpipeline render
      -- the status into tmux's bar instead.
      local group = vim.api.nvim_create_augroup("tpipeline_statusline", { clear = true })
      vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter" }, {
        group = group,
        callback = function()
          vim.opt.laststatus = 0
        end,
      })
    end,
  },
}
