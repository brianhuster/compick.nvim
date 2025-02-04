local M = {}

local function close_picker(win, buf)
	vim.api.nvim_win_close(win, true)
	vim.api.nvim_buf_delete(buf, { force = true })
	vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
end

local function get_center_position()
	return { math.floor(vim.o.lines / 2), math.floor(vim.o.columns / 2) }
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
		row = get_center_position()[1],
		border = "rounded",
		focusable = false,
		noautocmd = true,
	}
	win_opts.col = get_center_position()[2] - win_opts.width / 2

	for k, _ in pairs(win_opts) do
		if opts[k] ~= nil then
			win_opts[k] = opts[k]
		end
	end
	local win = vim.api.nvim_open_win(buf, true, win_opts)
	vim.cmd("startinsert")

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
	vim.api.nvim_create_autocmd("InsertCharPre", {
		buffer = buf,
		callback = function()
			local key = vim.keycode("<C-x><C-o>")
			vim.api.nvim_feedkeys(key, "m", false)
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

M.pick(function(base)
		return vim.fs.find(function(name, path)
			return not not path:match(base)
		end, {
			follow = true,
			limit = 10
		})
	end,
	function(text) vim.cmd.edit(text) end)

return M
