-- No autocompletion popup while writing prose.
local prose_filetypes = {
  markdown = true,
  text = true,
  gitcommit = true,
  ["markdown.mdx"] = true,
}

return {
  {
    "saghen/blink.cmp",
    opts = {
      enabled = function()
        return not prose_filetypes[vim.bo.filetype]
      end,
    },
  },
}
