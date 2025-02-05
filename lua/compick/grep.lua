local M = {}

M.cache = {}

function M.pick(initial_text)
	M.cache = {}
	require('compick').pick(function(base)
		if not base or base == "" then
			return {}
		end
		if M.cache[base] then
			return M.cache[base]
		end
		vim.system(vim.list_extend(vim.split(vim.o.grepprg:sub(1, -2), ' '), { base }), {
			text = true,
			stdout = function(_, data)
				if data then
					local data_list = vim.split(data, '\n')
					M.cache[base][#M.cache[base]] = M.cache[base][#M.cache[base]] .. data_list[1]
					for k = 2, #data_list do
						M.cache[base][#M.cache[base] + 1] = data_list[k]
					end
				end
				require('compick._').trigger_compl()
			end
		})
	end, function(selected)
		local item = vim.fn.getqflist({ lines = { selected }, efm = vim.o.grepformat }).items[1]
		if item.bufnr > 0 then
			vim.cmd.buffer(item.bufnr)
		end
		if item.lnum > 0 and item.col >= 0 then
			vim.api.nvim_win_set_cursor(0, { item.lnum, item.col })
		end
	end)
end

return M
