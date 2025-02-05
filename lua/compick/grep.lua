local M = {}

local cache = {}

function M.pick(initial_text)
	cache = {}
	require('compick').pick(function(base)
		if cache.base then
			return cache.base
		end
		vim.system({ unpack(vim.split(vim.o.grepprg, ' ')), base }, {
			text = true,
			on_stdout = function(_, out)
				cache.base = out
				require('compick._').trigger_compl()
			end
		})
	end, function(selected)
		local qflist = vim.fn.getqflist({ lines = { selected }, efm = vim.o.grepformat })
		vim.cmd.buffer(qflist[1].bufnr)
		vim.api.nvim_set_cursor(0, { qflist[1].lnum, qflist[1].col })
	end)
end

return M
