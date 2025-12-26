return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "c_sharp",
          "gdscript",
          "javascript",
          "typescript",
          "tsx",
          "json",
          "html",
          "css",
          "lua",
          "bash",
          "yaml",
          "toml",
          "markdown",
          "markdown_inline",
          "vim",
          "vimdoc",
          "regex",
        },
      })

      -- Enable highlighting for all filetypes
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
