-- vim-plugs
vim.cmd [[
  call plug#begin('~/.config/nvim/plugged')
  Plug 'preservim/nerdtree'
  Plug 'chrisbra/colorizer'
  Plug 'rebelot/kanagawa.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
	Plug 'echasnovski/mini.move'
	Plug 'echasnovski/mini-git'
	Plug 'echasnovski/mini.cursorword'
	Plug 'echasnovski/mini.indentscope'
	Plug 'echasnovski/mini.notify'
  call plug#end()
]]

-- Flip telescope search results
local asc = { sorting_strategy = "ascending" }
require("telescope").setup({
  defaults = asc,
  pickers = asc,
})

-- VimEnter configs
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    -- If no args, open find_files
    if vim.fn.argc() == 0 then
      vim.cmd "Telescope find_files"
    end

		SetColorScheme("darker")
  end,
})

-- Light/dark mode function
function SetColorScheme(mode)
	local kanagawa = require("kanagawa")
  if mode == "light" then
		vim.o.background = "light"
		kanagawa.load("lotus")
  elseif mode == "dark" then
		vim.o.background = "dark"
		kanagawa.load("wave")
	elseif mode == "darker" then
		vim.o.background = "dark"
		kanagawa.load("dragon")
  else
    print("Invalid argument: use 'light', 'dark', or 'darker'")
  end
end

-- Lock cursor function
function ToggleScrollLock()
  if vim.o.scrolloff == 999 then
    vim.o.scrolloff = 0
    print("Scroll lock disabled")
  else
    vim.o.scrolloff = 999
    print("Scroll lock enabled")
  end
end

-- Mason + mason-lspconfig setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {"lua_ls", "pyright", "ts_ls", "clangd"},
  automatic_installation = true,
})

-- Common on attach func for all LSPs
local telescope_builtin = require("telescope.builtin")
local function on_attach(client, bufnr)
  local opts = { noremap = true, silent = false, buffer = bufnr }

  vim.keymap.set("n", "gd", function()
    telescope_builtin.lsp_definitions({
      jump_type = "tab",
      reuse_win = false,
    })
  end, opts) -- Goto definitions in new buffer

  vim.keymap.set("n", "gr", telescope_builtin.lsp_references, opts) -- Find references
  vim.keymap.set("n", "gs", telescope_builtin.lsp_document_symbols, opts) -- Symbols in curr buff
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- Symbol details hover
  vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts) -- Rename symbol
  vim.keymap.set("n", "<S-e>", vim.diagnostic.open_float, opts) -- Show errors for selected line
end

-- Diagnostic settings for all LSPs
vim.diagnostic.config({
  signs = false,
  virtual_text = true,
  underline = true,
  update_in_insert = false,
})

-- Setup LSP servers
local lspconfig = require("lspconfig")
require("mason-lspconfig").setup_handlers({
  function(server_name)
		local opts = { on_attach = on_attach }

		-- Lua LS
    if server_name == "lua_ls" then
      opts.settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      }
    end

    lspconfig[server_name].setup(opts)
  end,
})

-- Setup mini stuff
-- Notify
require("mini.notify").setup({
	content = {
		format = nil,
		sort = nil,
	},
	lsp_progress = {
		enable = true,
		level = 'INFO',
		duration_last = 2000,
	},
	window = {
		config = {},
		max_width_share = 0.382,
		winblend = 25,
	},
})
-- Indent scope
require("mini.indentscope").setup({
	draw = {
		delay = 10,
	}
})
-- cursorword
require("mini.cursorword").setup({
	delay = 10,
})
-- git
require("mini.git").setup()
-- move
require("mini.move").setup({
	mappings = {
    -- Visual mode
    left = '<S-Left>',
    right = '<S-Right>',
    up = '<S-Up>',
    down = '<S-Down>',
    -- Normal mode (disabled)
		line_left = '',
		line_right = '',
		line_up = '',
		line_down = '',
	},
	options = {
		reindent_linewise = true,
	}
})

-- Custom commands
vim.api.nvim_create_user_command("Source", "source ~/.config/nvim/init.lua", {})
vim.api.nvim_create_user_command("Tree", "NERDTreeToggle", {})
vim.api.nvim_create_user_command("Light", function() SetColorScheme("light") end, {})
vim.api.nvim_create_user_command("Dark", function() SetColorScheme("dark") end, {})
vim.api.nvim_create_user_command("Darker", function() SetColorScheme("darker") end, {})
vim.api.nvim_create_user_command("Lock", function() ToggleScrollLock() end, {})

-- Keybinds
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = false }

map("v", "<Leader>y", '"+y', opts)
map("n", "<Leader>y", '"+yy', opts)
map("n", "<Tab>", ":tabnext<CR>", opts)
map("n", "<S-Tab>", ":tabprevious<CR>", opts)
map("n", "<S-w>", ":q<CR>", opts)
map("n", "F", ":Telescope find_files<CR>", opts)
map("n", "f", ":Telescope current_buffer_fuzzy_find<CR>", opts)
map("n", "<Leader>f", ":Telescope live_grep<CR>", opts)
map("n", "/", ":nohlsearch<CR>/", opts)


-- Other
vim.o.smartindent = true	-- Auto indent based on syntax
vim.o.autoindent = true		-- Enable auto indentation
vim.o.expandtab = true		-- Spaces instead of tab chars
vim.o.tabstop = 2					-- Num spaces per tab
vim.o.shiftwidth = 2			-- Num spaces for each step of auto indent
vim.o.softtabstop = 2			-- Num spaces Tab generates in insert mode
vim.o.smarttab = true			-- Insert tabs based on current indent level

vim.o.number = true				-- Line numbers
vim.o.scrolloff = 999     -- Keep cursor centered unless at top or bottom
