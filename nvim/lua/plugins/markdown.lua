return {
  -- Live preview in browser
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
    keys = {
      { "<Leader>mp", "<Cmd>MarkdownPreviewToggle<CR>", desc = "Toggle Markdown Preview" },
    },
    init = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },

  -- Render markdown in Neovim buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    event = { "BufReadPre *.md", "BufNewFile *.md" },
    opts = {
      heading = {
        enabled = true,
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
      },
      code = {
        enabled = true,
        style = "full",
      },
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "☐ " },
        checked = { icon = "☑ " },
      },
    },
    keys = {
      { "<Leader>mr", "<Cmd>RenderMarkdown toggle<CR>", desc = "Toggle Markdown Render" },
    },
  },

  -- Easy table formatting
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown" },
    event = { "BufReadPre *.md", "BufNewFile *.md" },
    config = function()
      vim.g.table_mode_corner = "|"
    end,
    keys = {
      { "<Leader>mt", "<Cmd>TableModeToggle<CR>", desc = "Toggle Table Mode" },
    },
  },
}
