return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    opts.enabled = function()
      local filetype = vim.bo.filetype
      if filetype == "markdown" or filetype == "text" then
        return false
      end
      return true
    end
  end,
}
