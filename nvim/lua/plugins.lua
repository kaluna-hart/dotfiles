local status, packer = pcall(require, "packer")
if not status then
  print("Packer is not installed")
  return
end

vim.cmd([[packadd packer.nvim]])

packer.startup(function(use)
  use("wbthomason/packer.nvim")

  use("norcalli/nvim-colorizer.lua")
  use("marko-cerovac/material.nvim")
  use({ "bluz71/vim-moonfly-colors", as = "moonfly" })

  use({
    "nvim-lualine/lualine.nvim",
    requires = { "nvim-tree/nvim-web-devicons", opt = true },
  })
  use("nvim-lua/plenary.nvim")
  use("neovim/nvim-lspconfig")
  use("jose-elias-alvarez/null-ls.nvim")
  use("MunifTanjim/prettier.nvim")
  use("williamboman/mason.nvim")
  use("williamboman/mason-lspconfig.nvim")
  use({
    "nvimdev/lspsaga.nvim",
    after = "nvim-lspconfig",
    config = function()
      require("lspsaga").setup({
        lightbulb = {
          enable = false,
          enable_in_insert = true,
          sign = true,
          sign_priority = 40,
          virtual_text = true,
        },
      })
    end,
  })

  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end,
  })
  use("nvim-tree/nvim-web-devicons")
  use("nvim-telescope/telescope.nvim")
  use({ "nvim-telescope/telescope-file-browser.nvim" })
  use({
    "AckslD/nvim-neoclip.lua",
    requires = { "tami5/sqlite.lua" },
  })
  use("onsails/lspkind.nvim")
  use("nvim-tree/nvim-tree.lua")
  use("numToStr/Comment.nvim")
  use("windwp/nvim-ts-autotag")
  use("lukas-reineke/indent-blankline.nvim")
  use({ "akinsho/toggleterm.nvim", tag = "*" })
  use({ "akinsho/bufferline.nvim", tag = "*", requires = "nvim-tree/nvim-web-devicons" })
  use({ "xiyaowong/nvim-transparent" })

  use({ "machakann/vim-sandwich" })
  use({ "andymass/vim-matchup" })
  use({ "liuchengxu/vista.vim" })
  use({ "cohama/lexima.vim" })
  use({ "tpope/vim-repeat" })

  use("lewis6991/gitsigns.nvim")
  use({
    "dinhhuy258/git.nvim",
  })

  use({
    "hrsh7th/nvim-cmp",
  })
  use({ "hrsh7th/cmp-nvim-lsp" })
  use({ "hrsh7th/cmp-buffer" })
  use({ "hrsh7th/cmp-path" })
  use({ "hrsh7th/cmp-cmdline" })
  use({ "L3MON4D3/LuaSnip" })
  use({ "saadparwaiz1/cmp_luasnip" })
  -- use({ "hrsh7th/cmp-vsnip" })
  -- use({ "hrsh7th/vim-vsnip" })
  use({ "ray-x/cmp-treesitter" })
  use("rafamadriz/friendly-snippets")

  -- use("vim-denops/denops.vim")
  -- use({ "Shougo/ddc.vim", requires = { "vim-denops/denops.vim" } })
  -- use("Shougo/ddc-around")
  -- use("Shougo/ddc-matcher_head")
  -- use("Shougo/ddc-sorter_rank")
  -- use("Shougo/ddc-converter_remove_overlap")
  -- use("Shougo/ddc-nvim-lsp")
  -- use("Shougo/ddc-omni")
  -- use("Shougo/ddc-file")
  -- use("hrsh7th/vim-vsnip-integ")
  -- use({ "hrsh7th/vim-vsnip", requires = { "hrsh7th/vim-vsnip-integ", "rafamadriz/friendly-snippets" } })

  use("j-hui/fidget.nvim")
  -- use("matsui54/denops-signature_help")
  -- use("matsui54/denops-popup-preview.vim")
  use({
    "rust-lang/rust.vim",
    ft = { "rust" },
    config = function()
      vim.g.rustfmt_autosave = 1
    end,
  })
  use({
    "styled-components/vim-styled-components",
    ft = { "javascript", "javascript.jsx", "javascriptreact", "typescript", "typescript.tsx", "typescriptreact" },
    config = function()
      vim.cmd([[source ~/.config/nvim/dein/plugins/vim-styled-components.plug.vim]])
    end,
  })
  use({
    "phaazon/hop.nvim",
    branch = "v2",
    config = function()
      require("hop").setup({ key = "etovxqpdygfblzhckisuran" })
    end,
  })
  use({ "folke/todo-comments.nvim", requires = { "nvim-lua/plenary.nvim" } })
  use({
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  })
  use({
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  })
  -- use({
  --   "github/copilot.vim",
  --   config = function()
  --     vim.g.copilot_no_tab_map = true
  --
  --     local keymap = vim.keymap.set
  --     -- https://github.com/orgs/community/discussions/29817#discussioncomment-4217615
  --     keymap(
  --       "i",
  --       "<C-o>",
  --       'copilot#Accept("<CR>")',
  --       { noremap = true, silent = true, expr = true, script = true, replace_keycodes = false }
  --     )
  --     keymap("i", "<C-j>", "<Plug>(copilot-next)")
  --     keymap("i", "<C-k>", "<Plug>(copilot-previous)")
  --     keymap("i", "<C-d>", "<Plug>(copilot-dismiss)")
  --     keymap("i", "<C-s>", "<Plug>(copilot-suggest)")
  --   end,
  -- })
end)
