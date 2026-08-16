-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Keep raw markdown source visible (code fences, bold asterisks, link syntax).
-- render-markdown.nvim sets conceallevel=2 by default; we reset it to 0 so
-- nothing gets hidden while editing. Virtual-text overlays (icons, borders)
-- still render since those use extmarks, not conceal.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "dockerfile",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})
