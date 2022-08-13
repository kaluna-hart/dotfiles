local status, packer = pcall(require, "packer")
if (not status) then
  print("Packer is not installed")
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'norcalli/nvim-colorizer.lua'
  use 'marko-cerovac/material.nvim'

  use {
  'nvim-lualine/lualine.nvim',
  requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use 'nvim-lua/plenary.nvim'
  use 'neovim/nvim-lspconfig'
  use 'jose-elias-alvarez/null-ls.nvim'
  use 'MunifTanjim/prettier.nvim'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'kyazdani42/nvim-web-devicons'
  use 'nvim-telescope/telescope.nvim'
  use {
    'AckslD/nvim-neoclip.lua',
    requires = { 'tami5/sqlite.lua' }
  }
  use 'onsails/lspkind-nvim'
  use 'kyazdani42/nvim-tree.lua'
  use 'numToStr/Comment.nvim'
  use 'windwp/nvim-ts-autotag'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'petertriho/nvim-scrollbar'
  use { 'akinsho/toggleterm.nvim', tag = 'v2.*' }
  use { 'akinsho/bufferline.nvim',
        tag = "v2.*",
        requires = 'kyazdani42/nvim-web-devicons'
  }
  use { 'xiyaowong/nvim-transparent' }

  use { 'machakann/vim-sandwich', opt = true }
  use { 'andymass/vim-matchup', opt = true }
  use { 'liuchengxu/vista.vim', opt = true }
  use { 'cohama/lexima.vim', opt = true }
  use { 'tpope/vim-repeat', opt = true }

  use 'lewis6991/gitsigns.nvim'
  use {
  'dinhhuy258/git.nvim'
  }

  use 'vim-denops/denops.vim'
  use { 'Shougo/ddc.vim', requires = { 'vim-denops/denops.vim' } }
  use 'Shougo/ddc-around'
  use 'Shougo/ddc-matcher_head'
  use 'Shougo/ddc-sorter_rank'
  use 'Shougo/ddc-converter_remove_overlap'
  use 'Shougo/ddc-nvim-lsp'
  use 'Shougo/ddc-omni'
  use 'Shougo/ddc-file'
  use 'hrsh7th/vim-vsnip-integ'
  use 'rafamadriz/friendly-snippets'
  use { 'hrsh7th/vim-vsnip',
        requires = { 'hrsh7th/vim-vsnip-integ', 'rafamadriz/friendly-snippets' },
  }
  use  'j-hui/fidget.nvim'
  use 'matsui54/denops-signature_help'
  use 'matsui54/denops-popup-preview.vim'
  use { 'rust-lang/rust.vim',
      ft = { 'rust' },
      config = function() vim.g.rustfmt_autosave = 1 end,
    }
  use { 'styled-components/vim-styled-components',
        ft = { 'javascript','javascript.jsx', 'javascriptreact', 'typescript', 'typescript.tsx', 'typescriptreact' },
        config = function() vim.cmd([[source ~/.config/nvim/dein/plugins/vim-styled-components.plug.vim]]) end,
      }
end)
