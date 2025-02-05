return {
	---@type function
	---@param findstart 1|0
	---@param base string?
	---@diagnostic disable-next-line: unused-local
	omnifunc = function(findstart, base) end,

	trigger_compl = function()
		local key = vim.keycode("<C-x><C-o>")
		vim.api.nvim_feedkeys(key, "m", false)
	end
}
