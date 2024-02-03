-- You don't need to set any of these options.
-- IMPORTANT!: this is only a showcase of how you can set default options!
local telescope = require("telescope")
local trouble = require("trouble.providers.telescope")

telescope.setup({
	extensions = {
		file_browser = {
			theme = "ivy",
			-- disables netrw and use telescope-file-browser in its place
			hijack_netrw = true,
			mappings = {
				["i"] = {
					-- your custom insert mode mappings
					["<c-t>"] = trouble.open_with_trouble,
				},
				["n"] = {
					-- your custom normal mode mappings
					["<c-t>"] = trouble.open_with_trouble,
				},
			},
		},
		aerial = {
			-- Display symbols as <root>.<parent>.<symbol>
			show_nesting = {
				["_"] = false, -- This key will be the default
				json = true, -- You can set the option for specific filetypes
				yaml = true,
			},
		},
	},
})
-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
telescope.load_extension("file_browser")
telescope.load_extension("aerial")
telescope.load_extension("notify")
telescope.load_extension("lazygit")
-- telescope.load_extension('dap')
