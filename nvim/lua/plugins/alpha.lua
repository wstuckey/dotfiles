return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")

      local header = {
        type = "text",
        val = {
          [[                                             o8o                    ]],
          [[                                             `"'                    ]],
          [[ooo. .oo.    .ooooo.   .ooooo.  oooo    ooo oooo  ooo. .oo.  .oo.   ]],
          [[`888P"Y88b  d88' `88b d88' `88b  `88.  .8'  `888  `888P"Y88bP"Y88b  ]],
          [[ 888   888  888ooo888 888   888   `88..8'    888   888   888   888  ]],
          [[ 888   888  888    .o 888   888    `888'     888   888   888   888  ]],
          [[o888o o888o `Y8bod8P' `Y8bod8P'     `8'     o888o o888o o888o o888o ]],
        },
        opts = {
          hl = "Type",
          position = "center",
        },
      }

      local button_text = {
        type = "text",
        val = {
          "       [e] New file           [x] Explorer      ",
          "       [f] Find file          [c] Config        ",
          "       [g] Grep text          [l] Lazy          ",
          "       [r] Recent files       [q] Quit          ",
        },
        opts = {
          hl = "Keyword",
          position = "center",
        },
      }

      -- Set up keymaps for the dashboard
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "alpha",
        callback = function()
          local opts = { buffer = true, noremap = true, silent = true }
          vim.keymap.set("n", "e", function() vim.cmd("ene") end, opts)
          vim.keymap.set("n", "f", function() require("telescope.builtin").find_files() end, opts)
          vim.keymap.set("n", "g", function() require("telescope.builtin").live_grep() end, opts)
          vim.keymap.set("n", "r", function() require("telescope.builtin").oldfiles() end, opts)
          vim.keymap.set("n", "x", function() require("neo-tree.command").execute({ toggle = true }) end, opts)
          vim.keymap.set("n", "c", function() vim.cmd("e $MYVIMRC") end, opts)
          vim.keymap.set("n", "l", function() vim.cmd("Lazy") end, opts)
          vim.keymap.set("n", "q", function() vim.cmd("qa") end, opts)
        end,
      })

      local config = {
        layout = {
          { type = "padding", val = 2 },
          header,
          { type = "padding", val = 2 },
          button_text,
        },
        opts = {
          margin = 5,
        },
      }

      alpha.setup(config)
    end,
  },
}
