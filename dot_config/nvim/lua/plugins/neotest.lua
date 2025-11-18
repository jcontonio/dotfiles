return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-jest",
  },
  opts = {
    adapters = {
      ["neotest-jest"] = {
        -- Point to your jest config in the src directory
        jestCommand = "./node_modules/.bin/jest",
        env = {
          NODE_ENV = "test",
          -- Match your test:coverage script
          NODE_OPTIONS = "--max-old-space-size=8192",
        },
        cwd = function()
          return vim.fn.getcwd()
        end,
      },
    },
  },
}
