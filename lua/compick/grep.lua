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
		local grepcmd = vim.split(vim.o.grepprg:sub(1, -2), ' ')
		local added_args = false
		grepcmd = vim.tbl_map(function(x)
			if x == '%s' then
				added_args = true
				return base
			elseif x == '%' or x == '#' then
				return vim.fn.expand(x)
			else
				return x
			end
		end, grepcmd)
		if not added_args then
			grepcmd[#grepcmd + 1] = base
		end
		vim.print(grepcmd)
		vim.system(grepcmd, {
			text = true,
			timeout = 0.1,
			stdout = function(_, data)
				if data then
					local data_list = vim.split(data, '\n')
					if not M.cache[base] then
						M.cache[base] = data_list
					end
					M.cache[base][#M.cache[base]] = M.cache[base][#M.cache[base]] .. data_list[1]
					for k = 2, #data_list do
						M.cache[base][#M.cache[base] + 1] = data_list[k]
					end
				end
			end
		}, function() end)
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
