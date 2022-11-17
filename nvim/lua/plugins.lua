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

	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})
	use("nvim-lua/plenary.nvim")
	use("neovim/nvim-lspconfig")
	use("jose-elias-alvarez/null-ls.nvim")
	use("MunifTanjim/prettier.nvim")
	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")
	use({
		"glepnir/lspsaga.nvim",
		branch = "main",
	})

	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})
	use("kyazdani42/nvim-web-devicons")
	use("nvim-telescope/telescope.nvim")
	use({ "nvim-telescope/telescope-file-browser.nvim" })
	use({
		"AckslD/nvim-neoclip.lua",
		requires = { "tami5/sqlite.lua" },
	})
	use("onsails/lspkind.nvim")
	use("kyazdani42/nvim-tree.lua")
	use("numToStr/Comment.nvim")
	use("windwp/nvim-ts-autotag")
	use("lukas-reineke/indent-blankline.nvim")
	use({ "akinsho/toggleterm.nvim", tag = "v2.*" })
	use({ "akinsho/bufferline.nvim", tag = "v2.*", requires = "kyazdani42/nvim-web-devicons" })
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
	use({ "hrsh7th/cmp-vsnip" })
	use({ "hrsh7th/vim-vsnip" })
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
end)
