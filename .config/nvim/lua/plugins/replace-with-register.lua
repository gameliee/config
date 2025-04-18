return {
  "inkarkat/vim-ReplaceWithRegister",
  config = function()
    vim.api.nvim_set_keymap("n", "<Leader>r", "<Plug>ReplaceWithRegisterOperator", { noremap = false, silent = true })
    vim.api.nvim_set_keymap("v", "<Leader>r", "<Plug>ReplaceWithRegisterVisual", { noremap = false, silent = true })
  end,
}
