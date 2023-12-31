local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local opts_n = {
  mode = "n",     -- NORMAL mode
  prefix = nil,
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
}
local mappings_n = {
  ["m"] = { "<cmd>AerialToggle! float<CR>", "aerial" },
  ["["] = {
    E = { function() require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, "lspsaga diagnostic goto prev error" },
  },
  ["]"] = {
    E = { function() require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR }) end, "lspsaga diagnostic goto next error" },
  },
  ["<c-d>"] = { "<cmd>Lspsaga term_toggle<cr>", "lspsaga term toggle" },
  z = {
    name = "nvim-ufo",
    R = { require("ufo").openAllFolds, "ufo open all folds" },
    M = { require("ufo").closeAllFolds, "ufo close all folds" },
    r = { require("ufo").openFold, "ufo open fold" },
    m = { require("ufo").closeFold, "ufo close fold" },
    ["<cr>"] = { require("ufo").toggleFold, "ufo toggle fold" },
    K = { function()
      local winid = require("ufo").peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end }
  }
}
local opts_n_leader = {
  mode = "n",     -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
}
local mappings_n_leader = {
  g = {
    name = "git.nvim",
    b = { "<cmd>GitBlame<cr>", "git blame" },
    n = { "<cmd>GitCreatePullRequest<cr>", "git create pull request" },
    d = { "<cmd>GitDiff<cr>", "git diff" },
    D = { "<cmd>GitDiffClose<cr>", "git diff close" },
    r = { "<cmd>GitRevert<cr>", "git revert" },
    R = { "<cmd>GitRevertFile<cr>", "git revert file" },
  },
  ["ef"] = { "<cmd>NvimTreeToggle<cr>", "nvim tree" },
  l = {
    name = "lsp",
    D = { vim.lsp.buf.declaration, "lsp declaration" },
    i = { vim.lsp.buf.implementation, "lsp implementation" },
    w = {
      a = { vim.lsp.buf.add_workspace_folder, "lsp add workspace folder" },
      r = { vim.lsp.buf.remove_workspace_folder, "lsp remove workspace folder" },
      l = {
        function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end
        , "lsp list workspace folder" },
    },
    t = { vim.lsp.buf.type_definition, "lsp type definition" },
    f = { "<cmd>Lspsaga finder tyd+ref+def<cr>", "lspsaga finder tyd+ref+def" },
    -- f = { function() vim.lsp.buf.format { async = true } end, "lsp format" },
    c = {
      a = { "<cmd>Lspsaga code_action<cr>", "lspsaga code action" },
      i = { "<cmd>Lspsaga incoming_calls<cr>", "lspsaga incoming calls" },
      o = { "<cmd>Lspsaga outgoing_calls<cr>", "lspsaga outgoing calls" },
    },
    r = {
      r = { vim.lsp.buf.references, "lsp references" },
      n = { "<cmd>Lspsaga rename<cr>", "lspsaga rename" },
      p = { "<cmd>Lspsaga rename ++project<cr>", "lspsaga rename ++project" },
    },
    p = {
      d = { "<cmd>Lspsaga peek_definition<cr>", "lspsaga peek definition" },
      t = { "<cmd>Lspsaga peek_type_definition<cr>", "lspsaga peek type definition" },
    },
    g = {
      d = { "<cmd>Lspsaga goto_definition<cr>", "lspsaga goto definition" },
      t = { "<cmd>Lspsaga goto_type_definition<cr>", "lspsaga goto type definition" },
    },
    s = {
      l = { "<cmd>Lspsaga show_line_diagnostics<cr>", "lspsaga show line diagnostics" },
      c = { "<cmd>Lspsaga show_cursor_diagnostics<cr>", "lspsaga show cursor diagnostics" },
      b = { "<cmd>Lspsaga show_buffer_diagnostics<cr>", "lspsaga show buffer diagnostics" },
    },
    ["["] = { "<cmd>Lspsaga diagnostic_jump_prev<cr>", "lspsaga diagnostic jump prev" },
    ["]"] = { "<cmd>Lspsaga diagnostic_jump_next<cr>", "lspsaga diagnostic jump next" },
    o = { "<cmd>Lspsaga outline<cr>", "lspsaga outline" },
    h = { "<cmd>Lspsaga hover_doc<cr>", "lspsaga hover doc" },
    H = { "<cmd>Lspsaga hover_doc ++keep<cr>", "lspsaga hover doc ++keep" },
  },
  f = {
    f = { "<cmd>Telescope find_files hidden=true<cr>", "telescope find files hidden=true" },
    l = { "<cmd>Telescope live_grep<cr>", "telescope live grep" },
    b = { "<cmd>Telescope buffers<cr>", "telescope buffers" },
    h = { "<cmd>Telescope oldfiles<cr>", "telescope old files" },
    r = { "<cmd>Telescope file_browser<cr>", "telescope file browser" },
    a = { "<cmd>Telescope aerial<cr>", "telescope aerial" },
    n = { function() require("telescope").extensions.notify.notify() end, "telescope notify" },
    g = { "<cmd>Telescope lazygit<cr>", "telescope lazygit" },
    d = {
      name = "dap",
      c = { "<cmd>Telescope dap commands<cr>", "telescope dap commands" },
      o = { "<cmd>Telescope dap configurations<cr>", "telescope dap configurations" },
      l = { "<cmd>Telescope dap list_breakpoints<cr>", "telescope dap list breakpoints" },
      v = { "<cmd>Telescope dap variables<cr>", "telescope dap variables" },
      f = { "<cmd>Telescope dap frames<cr>", "telescope dap frames" },
    },
    c = { "<cmd>Telescope neoclip<cr>", "telescope neoclip" },
    t = { "<cmd>TodoTelescope<cr>", "todo telescope" },
  },
  c = {
    t = { "<cmd>CodyToggle<cr>", "cody toggle" },
  },
  L = { function()
    vim.schedule(function()
      if require("hlslens").exportLastSearchToQuickfix() then
        vim.cmd("cw")
      end
    end)
    return ":noh<cr>"
  end, "hlslens quickfix"
  }
}
local opts_v_leader = {
  mode = "n",     -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
}
local mappings_v_leader = {
  l = {
    name = "lsp",
    c = {
      a = { "<cmd>Lspsaga code_action<cr>", "lspsaga code action" },
    }
  }
}
local opts_x_leader = {
  mode = "x",     -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
}
local mappings_x_leader = {
  L = { function()
    vim.schedule(function()
      if require("hlslens").exportLastSearchToQuickfix() then
        vim.cmd("cw")
      end
    end)
    return ":noh<cr>"
  end, "hlslens quickfix"
  }
}
local opts_t = {
  mode = "t",     -- NORMAL mode
  prefix = nil,
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
}
local mappings_t = {
  ["<c-d>"] = { "<cmd>Lspsaga term_toggle<cr>", "lspsaga term toggle" },
}

which_key.setup(setup)
which_key.register(mappings, opts)
