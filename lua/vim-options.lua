
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set cursorline")
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.g.mapleader = " "

vim.keymap.set('n', '<leader>w', '<C-w>')
vim.keymap.set('i', 'jf', '<ESC>', {})
vim.keymap.set('n', ';', ':', {})
vim.keymap.set('n', ':', ';', {})

-- enable nvim copy and paste with system clipboard using yank and paste
vim.opt.clipboard = "unnamedplus"
if vim.fn.has('wsl') == 1 then
vim.api.nvim_create_autocmd('TextYankPost', {
group = vim.api.nvim_create_augroup('Yank', { clear = true }),
callback = function()
vim.fn.system('clip.exe', vim.fn.getreg('"'))
end,
})
end

-- setup softwrap, breaking between words and
-- indenting nicely paragraphs, lists, TODO
-- vim.opt.wrap = true //softwrap caused neorg concealer not working at linebreak
vim.opt.linebreak = true -- break on words
vim.opt.breakindent = true -- align wrapped line with previous indent level
vim.opt.textwidth = 90
vim.opt.breakindentopt = 'list:-1'
vim.opt.formatlistpat = '^\\s*[-~>]\\+\\s\\((.)\\s\\)\\?'


