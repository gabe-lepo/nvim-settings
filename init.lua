-- vim-plugs
vim.cmd [[
  call plug#begin('~/.config/nvim/plugged')
  Plug 'preservim/nerdtree'
  Plug 'chrisbra/colorizer'
  Plug 'rebelot/kanagawa.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-ui-select.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
	Plug 'echasnovski/mini.move'
	Plug 'echasnovski/mini-git'
	Plug 'echasnovski/mini.cursorword'
	Plug 'echasnovski/mini.indentscope'
	Plug 'echasnovski/mini.notify'
	Plug 'karb94/neoscroll.nvim'
  call plug#end()
]]

-- Telescope setup (flip search results)
require("telescope").setup({
  defaults = {
    sorting_strategy = "ascending",
    file_ignore_patterns = { "%.git/" },
  },
  pickers = {
    find_files = {
      hidden = true,
    }
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
    }
  },
})

-- Setup telescope ui select for lsp code actions
require("telescope").load_extension("ui-select")

-- VimEnter configs
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    -- If no args, open find_files
    if vim.fn.argc() == 0 then
      vim.cmd "Telescope find_files"
    end

    -- Script finder string!
		SetColorScheme("dark")
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
    vim.o.scrolloff = 10
    print("Scroll lock disabled")
  else
    vim.o.scrolloff = 999
    print("Scroll lock enabled")
  end
end

-- neoscroll setup
local neoscroll = require('neoscroll')
neoscroll.setup({
  mappings = {},
  hide_cursor = false,
  stop_eof = true,
  respect_scrolloff = false,
  cursor_scrolls_alone = true,
  duration_multiplier = 1.0,
  easing = 'linear',
  pre_hook = nil,
  post_hook = nil,
  performance_mode = false,
  ignored_events = {
      'WinScrolled', 'CursorMoved'
  },
})

-- Neoscroll custom maps
local nscroll_maps = {
  -- ["<S-Up>"] = function() neoscroll.ctrl_u({duration = 100}) end;
  -- ["<S-Down>"] = function() neoscroll.ctrl_d({duration = 100}) end;
  ["<S-Up>"] = function() neoscroll.scroll(-5, {duration=100}) end;
  ["<S-Down>"] = function() neoscroll.scroll(5, {duration=100}) end;
  ["zt"] = function() neoscroll.zt({half_win_duration = 100}) end;
  ["zz"] = function() neoscroll.zz({half_win_duration = 100}) end;
  ["zb"] = function() neoscroll.zb({half_win_duration = 100}) end;
}
local modes = { 'n' }
for key, func in pairs(nscroll_maps) do
  vim.keymap.set(modes, key, func)
end

-- Statusline mods
vim.o.statusline = "%f %{&modified ? '🔥' : ''} %="

-- Tabline modifications
vim.o.showtabline = 2 -- Always show tabline
vim.o.tabline = "%!v:lua.MyTabline()" -- Override with custom function

function _G.MyTabline()
  local tabline = ""
  for i = 1, vim.fn.tabpagenr("$") do
    local bufnr = vim.fn.tabpagebuflist(i)[1]
    local bufname = vim.fn.bufname(bufnr)
    local filename = vim.fn.fnamemodify(bufname, ":t")

    local modified = vim.fn.getbufvar(bufnr, "&modified") == 1

    if filename == "" then
      filename = "New Tab"
    end

    local modified_indicator = modified and " 🔥" or ""

    if i == vim.fn.tabpagenr() then
      -- Display to use for active tab
      tabline = tabline .. "%#TabLineSel#" .. " ▶ [" .. filename .. modified_indicator .. "] "
    else
      -- Display to use for inactive tabs
      tabline = tabline .. "%#TabLine#" .. " " .. filename .. modified_indicator .. " "
    end
  end
  return tabline
end

-- Mason + mason-lspconfig setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {"lua_ls", "pyright", "ts_ls", "clangd", "zls"},
  automatic_installation = true,
})

-- Common on attach func for all LSPs
local telescope_builtin = require("telescope.builtin")
local function on_attach(client, bufnr)
  -- LSP-focused keymaps
  local opts = { noremap = true, silent = false, buffer = bufnr }

  vim.keymap.set("n", "gd", function()
    telescope_builtin.lsp_definitions({
      jump_type = "tab",
      reuse_win = false,
    })
  end, opts) -- Goto definitions in new tab

  vim.keymap.set("n", "gt", function()
    telescope_builtin.lsp_type_definitions({
      jump_type = "tab",
      reuse_win = false,
    })
  end, opts) -- Goto type definitions in new tab

  vim.keymap.set("n", "<Leader>e", vim.diagnostic.open_float, opts) -- Show errors for selected line
  vim.keymap.set("n", "<Leader>E", function()
    telescope_builtin.diagnostics({
      bufnr = 0,
    })
  end, {noremap = true, silent = false}) -- Open document diagnostics/errors

  vim.keymap.set("n", "gr", telescope_builtin.lsp_references, opts) -- Find references
  vim.keymap.set("n", "<Leader>s", telescope_builtin.lsp_document_symbols, opts) -- Document symbols finder
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- Symbol details hover
  vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts) -- Rename symbol
  vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, opts) -- Open code actions window
  vim.keymap.set("n", "<Leader>b", telescope_builtin.buffers, opts) -- Open buffers picker
end

-- Diagnostic settings for all LSPs
vim.diagnostic.config({
  signs = false,
  virtual_text = true,
  underline = true,
  update_in_insert = false,
})

-- Setup LSP servers
require("mason-lspconfig").setup_handlers({
  function(server_name)
    local lspconfig = require("lspconfig")
		local opts = { on_attach = on_attach }

		-- Lua
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

		-- Zig (no auto formatting)
    if server_name == "zls" then
      vim.g.zig_fmt_autosave = 0
    end

    lspconfig[server_name].setup(opts)
  end,
})

-- Setup mini plugins
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

-- General keymaps
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = false }

map("v", "<Leader>y", '"+y', opts) -- Yank visual selections to clipboard
map("n", "<Leader>y", '"+yy', opts) -- Yank line to clipboard in normal mode
map("n", "<Tab>", ":tabnext<CR>", opts) -- Change tab
map("n", "<S-Tab>", ":tabprevious<CR>", opts) -- Change tab
map("n", "<S-w>", ":q<CR>", opts) -- Easy quit
map("n", "F", ":Telescope find_files<CR>", opts) -- Find files
map("n", "f", ":Telescope current_buffer_fuzzy_find<CR>", opts) -- FZF current buffer
map("n", "<Leader>f", ":Telescope live_grep<CR>", opts) -- Live grep
map("n", "/", ":nohlsearch<CR>/", opts) -- Clear previous search highlights
-- map("n", "<S-Up>", "5k", opts) -- Move cursor up 10 lines
-- map("n", "<S-Down>", "5j", opts) -- Move cursor down 10 lines
map("n", "<Leader>tr", ":tabmove +1<CR>", opts) -- Move current buffer tab right
map("n", "<Leader>tl", ":tabmove -1<CR>", opts) -- Move current buffer tab left

-- Other
vim.o.smartindent = true	-- Auto indent based on syntax
vim.o.autoindent = true		-- Enable auto indentation
vim.o.expandtab = true		-- Spaces instead of tab chars
vim.o.tabstop = 2					-- Num spaces per tab
vim.o.shiftwidth = 2			-- Num spaces for each step of auto indent
vim.o.softtabstop = 2			-- Num spaces Tab generates in insert mode
vim.o.smarttab = true			-- Insert tabs based on current indent level

vim.o.number = true				-- Line numbers
vim.o.scrolloff = 10      -- Screen only moves when cursor is +- 10 lines from screen edges
