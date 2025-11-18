return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      default = {
        -- Keep only the important coding sources
        "lsp",
        "path",
        "luasnip",
      },
      -- Disable the buffer source completely
      disabled = { "buffer" },
    },
  },
}
