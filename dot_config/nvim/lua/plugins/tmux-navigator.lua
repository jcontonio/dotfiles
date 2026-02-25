local mappings = {}

if vim.loop.os_uname().sysname == "Darwin" then
  mappings = {
    { "<D-M-Left>", "<cmd>TmuxNavigateLeft<cr>" },
    { "<D-M-Right>", "<cmd>TmuxNavigateRight<cr>" },
    { "<D-M-Up>", "<cmd>TmuxNavigateUp<cr>" },
    { "<D-M-Down>", "<cmd>TmuxNavigateDown<cr>" },
  }
else
  mappings = {
    { "<C-M-Left>", "<cmd>TmuxNavigateLeft<cr>" },
    { "<C-M-Right>", "<cmd>TmuxNavigateRight<cr>" },
    { "<C-M-Up>", "<cmd>TmuxNavigateUp<cr>" },
    { "<C-M-Down>", "<cmd>TmuxNavigateDown<cr>" },
  }
end

return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    config = function()
      local i = 1
      for i = 1, #mappings do
        vim.keymap.set("n", mappings[i][1], mappings[i][2], { silent = true })
      end
    end,
  },
}
