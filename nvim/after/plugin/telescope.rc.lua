-- You don't need to set any of these options.
-- IMPORTANT!: this is only a showcase of how you can set default options!
local telescope = require("telescope")

telescope.setup({
	extensions = {
		file_browser = {
			theme = "ivy",
			-- disables netrw and use telescope-file-browser in its place
			hijack_netrw = true,
			mappings = {
				["i"] = {
					-- your custom insert mode mappings
				},
				["n"] = {
					-- your custom normal mode mappings
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

local keymap = vim.keymap

keymap.set("n", "[telescope]", "<nop>")
keymap.set("n", "<leader>f", "[telescope]", { remap = true })
keymap.set("n", "[telescope]f", "<cmd>Telescope find_files hidden=true<cr>")
keymap.set("n", "[telescope]l", "<cmd>Telescope live_grep<cr>")
keymap.set("n", "[telescope]b", "<cmd>Telescope buffers<cr>")
keymap.set("n", "[telescope]h", "<cmd>Telescope oldfiles<cr>")
keymap.set("n", "[telescope]g", "<cmd>Telescope git_branches<cr>")
keymap.set("n", "[telescope]r", ":Telescope file_browser<cr>")
keymap.set("n", "[telescope]a", ":Telescope aerial<cr>")
keymap.set("n", "[telescope]n", function()
	telescope.extensions.notify.notify()
end)
