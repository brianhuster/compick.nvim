local M = {}

local function close_picker(win, buf)
	vim.api.nvim_win_close(win, true)
	vim.api.nvim_buf_delete(buf, { force = true })
	vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
end

--- @param choices table|function
--- @param on_select function
--- @param opts table?
function M.pick(choices, on_select, opts)
	assert(type(choices) == "table" or type(choices) == "function", "choices must be a table or function")
	assert(type(on_select) == "function", "on_select must be a function")
	opts = opts or {}
	assert(type(opts) == "table", "opts must be a table or nil")

	--- Create the picker window
	local buf = vim.api.nvim_create_buf(false, true)
	local win_opts = {
		relative = "editor",
		width = 20,
		height = 1,
		row = 0,
		col = 1,
		border = "rounded",
		focusable = false,
		noautocmd = true,
	}

	for k, _ in pairs(win_opts) do
		if opts[k] ~= nil then
			win_opts[k] = opts[k]
		end
	end
	local win = vim.api.nvim_open_win(buf, true, win_opts)
	vim.cmd("startinsert")
	if opts.initial_text then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { opts.initial_text })
		vim.api.nvim_win_set_cursor(win, { 1, #opts.initial_text })
	end

	--- Setup the window and picker
	vim.wo[win].number = false

	require('compick._').omnifunc = function(findstart, base)
		if findstart == 1 then
			return 0
		else
			if type(choices) == "table" then
				return vim.fn.matchfuzzy(choices, base)
			else
				return choices(base)
			end
		end
	end

	vim.bo[buf].omnifunc = "v:lua.require'compick._'.omnifunc"
	vim.bo[buf].completeopt = "menu,menuone,noinsert,noselect,popup"
	vim.api.nvim_create_autocmd("WinLeave", {
		buffer = buf,
		callback = function()
			close_picker(win, buf)
		end
	})
	vim.api.nvim_create_autocmd("TextChangedI", {
		buffer = buf,
		callback = function()
			require('compick._').trigger_compl()
		end
	})
	vim.api.nvim_create_autocmd('CompleteDone', {
		buffer = buf,
		callback = function()
			local item = vim.v.completed_item.word
			if item then
				close_picker(win, buf)
				on_select(item)
			end
		end
	})
end

return M
