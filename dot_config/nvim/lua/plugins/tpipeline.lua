return {
  {
    "vimpostor/vim-tpipeline",
    cond = function()
      return vim.env.TMUX ~= nil
    end,
    event = "VeryLazy",
    init = function()
      -- Use explicit embedding with lualine bridge.
      vim.g.tpipeline_autoembed = 0
      vim.g.tpipeline_statusline = ""
      vim.g.tpipeline_clearstl = 1
      vim.g.tpipeline_restore = 1
    end,
    config = function()
      -- Keep Neovim's own statusline row hidden while inside tmux.
      vim.opt.laststatus = 0
      vim.opt.cmdheight = 0
      vim.opt.showmode = false
      vim.opt.ruler = false
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      if vim.env.TMUX == nil then
        return opts
      end

      local nvim_opts = require("lualine.utils.nvim_opts")

      if nvim_opts._tpipeline_patched then
        return opts
      end

      local original_set = nvim_opts.set

      nvim_opts.set = function(name, value, scope)
        if name == "statusline" and scope and scope.window == vim.api.nvim_get_current_win() then
          vim.g.tpipeline_statusline = value
          vim.cmd("silent! call tpipeline#update()")
          return
        end

        return original_set(name, value, scope)
      end

      nvim_opts._tpipeline_patched = true
      return opts
    end,
  },
}
