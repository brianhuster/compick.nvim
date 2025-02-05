vim.api.nvim_create_user_command("Grep", function()
	require('compick.grep').pick()
end, {})
