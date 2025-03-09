-- vim-plugs
vim.cmd [[
  call plug#begin('~/.config/nvim/plugged')
  Plug 'preservim/nerdtree'
  Plug 'folke/tokyonight.nvim'
  Plug 'chrisbra/colorizer'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'rebelot/kanagawa.nvim'
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

-- Mason + mason-lspconfig setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {"lua_ls", "pyright", "ts_ls", "zls"},
  automatic_installation = true,
})

-- Common on attach func for all LSPs
local telescope_builtin = require("telescope.builtin")
local function on_attach(client, bufnr)
  local opts = { noremap = true, silent = false, buffer = bufnr }

  vim.keymap.set("n", "gd", telescope_builtin.lsp_definitions, opts) -- Goto definitions
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
  update_in_insert = true,
})

-- Autosetup installed LSP servers
local lspconfig = require("lspconfig")
require("mason-lspconfig").setup_handlers({
  function(server_name)
    local opts = { on_attach = on_attach }

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

-- Custom commands
vim.api.nvim_create_user_command("Source", "source ~/.config/nvim/init.lua", {})
vim.api.nvim_create_user_command("Tree", "NERDTreeToggle", {})
vim.api.nvim_create_user_command("Gstat", "Telescope git_status", {})
vim.api.nvim_create_user_command("Glog", "Telescope git_commits", {})
vim.api.nvim_create_user_command("Light", function() SetColorScheme("light") end, {})
vim.api.nvim_create_user_command("Dark", function() SetColorScheme("dark") end, {})
vim.api.nvim_create_user_command("Darker", function() SetColorScheme("darker") end, {})

-- Keybinds
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = false }

map("v", "<Leader>y", '"+y', opts)
map("n", "<Leader>y", '"+yy', opts)
map("n", "<Tab>", ":tabnext<CR>", opts)
map("n", "<S-Tab>", ":tabprevious<CR>", opts)
map("n", "<S-w>", ":tabclose<CR>", opts)
map("n", "F", ":Telescope find_files<CR>", opts)
map("n", "f", ":Telescope current_buffer_fuzzy_find<CR>", opts)
map("n", "<Leader>f", ":Telescope live_grep<CR>", opts)
map("n", "/", ":nohlsearch<CR>/", opts)


-- Other basics
vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.o.scrolloff = 999 -- Keep cursor centered unless at top or bottom
