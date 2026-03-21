return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true, -- this is the key one for the explorer
          },
          files = {
            hidden = true, -- for file picker (<leader>ff)
          },
          grep = {
            hidden = true, -- for grep (<leader>sg)
          },
        },
      },
    },
  },
}
