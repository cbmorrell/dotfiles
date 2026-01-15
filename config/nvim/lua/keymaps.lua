-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Center cursor when jumping up and down
vim.keymap.set('n', '<C-d>', '<C-d>zz', {noremap = true, silent = true})
vim.keymap.set('n', '<C-u>', '<C-u>zz', {noremap = true, silent = true})

-- Toggle undotree
vim.keymap.set('n', '<leader><F5>', vim.cmd.UndotreeToggle)

-- Leap motions (custom bidirectional)
vim.keymap.set('n', 's', '<Plug>(leap)')
-- vim: ts=2 sts=2 sw=2 et

-- Navigate between panes
vim.keymap.set('n', '<C-h>', '<C-w>h', {noremap = true, silent = true})
vim.keymap.set('n', '<C-j>', '<C-w>j', {noremap = true, silent = true})
vim.keymap.set('n', '<C-k>', '<C-w>k', {noremap = true, silent = true})
vim.keymap.set('n', '<C-l>', '<C-w>l', {noremap = true, silent = true})

-- CodeCompanion
vim.keymap.set({ "n", "v" }, "<leader>cp", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true, desc = 'Command Palette'})
vim.keymap.set({ "n", "v" }, "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true, desc = 'Open Chat'})
vim.keymap.set("v", "<leader>ca", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true, desc = 'Add to Chat'})

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])

-- File Navigation
local tree_api = require "nvim-tree.api"
vim.keymap.set("n", "<leader>pv", "<cmd>vsplit<cr>", { desc = "Vsplit current buffer" })
vim.keymap.set("n", "<leader>ph", "<cmd>split<cr>", { desc = "Hsplit current buffer" })
vim.keymap.set("n", "<leader>px", "<cmd>only<cr>", { desc = "Close all other buffers" })
vim.keymap.set("n", "<leader>pf", tree_api.tree.toggle, { desc = "Toggle File Tree" })
vim.keymap.set("n", "<leader>po", tree_api.tree.find_file, { desc = "Find file" })

-- Harpoon
local harpoon = require("harpoon")

vim.keymap.set("n", "<leader>pa", function() harpoon:list():add() end, { desc = 'Add to Harpoon List'})
vim.keymap.set("n", "<leader>ps", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Open Harpoon Menu'})
vim.keymap.set("n", "<leader>pc", function() harpoon:list():clear() end, { desc = 'Clear Harpoon List'})

vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)


-- Git
local function toggle_fugitive()
  local closed_any = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("^fugitive://") then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
      closed_any = true
    end
  end

  if not closed_any then
    vim.cmd("Git")
  end
end

vim.keymap.set("n", "<leader>gt", toggle_fugitive, {
  desc = "Toggle Fugitive status",
})

