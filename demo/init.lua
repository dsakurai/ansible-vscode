-- BEGIN Plugins managed by Ansible --
-- Remember fold states
local remember_folds_group = vim.api.nvim_create_augroup("remember_folds", { clear = true })
--
local function should_do_view(buf)
  if vim.bo[buf].buftype ~= "" then return false end     -- nohelp, noquickfix, etc.
  if vim.bo[buf].filetype == "" then return false end    -- optional
  local name = vim.api.nvim_buf_get_name(buf)
  if name == nil or name == "" then return false end     -- no [No Name]
  if vim.fn.filereadable(name) == 0 then return false end -- not a real file
  return true
end

-- Save state
vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost", "BufHidden", "QuitPre" }, {
  group = remember_folds_group,
  callback = function(args)
    if should_do_view(args.buf) then
      pcall(vim.cmd, "silent! mkview!")
    end
  end
})

-- Load state
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = remember_folds_group,
  callback = function(args)
    if should_do_view(args.buf) then
      pcall(vim.cmd, "silent! loadview")
    end
  end
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=v11.17.5", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Conceal doesn't work with line wrapping
vim.opt.conceallevel = 0

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here

    -- obsidian
    {
      "obsidian-nvim/obsidian.nvim",
      version = "v3.16.2",
      ft = "markdown",
      opts = {
        note_id_func = function(title)
          return title
        end,
        ui = {
          enable = false,
        },
        checkbox = {
          enabled = true,
          create_new = true,
          order = {" ", ">", "x"},
        },
        workspaces = {
          {
            name = "private",
            path = "/workspaces/dotfiles-generator/demo/obsidian"
          },
        },
        new_notes_location = "notes_subdir",
        notes_subdir = "Notes",
        templates = {
          folder = "Support/Templates",
        }
      },
    },
              
    -- Completion (works with Obsidian.nvim) -- https://cmp.saghen.dev/installation
    { 'saghen/blink.cmp',
      -- optional: provides snippets for the snippet source
      -- dependencies = { 'rafamadriz/friendly-snippets' },

      -- use a release tag to download pre-built binaries
      version = '1.*',
      -- AND/OR build from source
      -- build = 'cargo build --release',
      -- If you use nix, you can build from source with:
      -- build = 'nix run .#build-plugin',

      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        keymap = {
          -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
          -- 'super-tab' for mappings similar to vscode (tab to accept)
          -- 'enter' for enter to accept
          -- 'none' for no mappings
          --
          -- All presets have the following mappings:
          -- C-space: Open menu or open docs if already open
          -- C-n/C-p or Up/Down: Select next/previous item
          -- C-e: Hide menu
          -- C-k: Toggle signature help (if signature.enabled = true)
          --
          -- See :h blink-cmp-config-keymap for defining your own keymap

          -- preset = 'default',
          preset = 'enter',

          ['<Tab>']   = {'show', 'select_next', 'fallback'},
          ['<S-Tab>'] = {        'select_prev', 'fallback'},
         },
        
        -- 
        -- enabled = function() return not vim.tbl_contains({"markdown"}, vim.bo.filetype) end,
        -- cmdline = {enabled = false},

        appearance = {
          -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
          -- Adjusts spacing to ensure icons are aligned
          nerd_font_variant = 'mono'
        },

        completion = {
          menu = {
            auto_show = false, -- Only show the completion when manually triggered
          },
          -- (Default) Only show the documentation popup when manually triggered
          documentation = { auto_show = false }
          },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
        -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
        --
        -- See the fuzzy documentation for more information
        fuzzy = { implementation = "prefer_rust_with_warning" }
      },
      opts_extend = { "sources.default" }
    },

    -- I don't think we need this for nvim-orgmode to function.
    {"nvim-treesitter/nvim-treesitter",
        version = "v0.10.0",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require'nvim-treesitter.configs'.setup({
              highlight = {
                enable = true,
              },
              ensure_installed = {
                "markdown",
                "markdown_inline",
              }
            })
        end,
    },

  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  -- install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
-- END Plugins managed by Ansible --
