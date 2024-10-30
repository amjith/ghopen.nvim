local M = {}

function M.open_in_github()
	-- Get the current file path
	local file_path = vim.fn.expand("%:p")

	-- Get the git root directory
	local git_root = vim.fn.system("git -C " .. vim.fn.expand("%:p:h") .. " rev-parse --show-toplevel"):gsub("\n", "")

	if vim.v.shell_error ~= 0 then
		print("Not a git repository")
		return
	end

	-- Get the current branch
	local branch = vim.fn.system("git -C " .. git_root .. " rev-parse --abbrev-ref HEAD"):gsub("\n", "")

	-- Get the remote URL
	-- local remote_url = vim.fn.system("git ls-remote --get-url origin"):gsub("\n", "")
	local remote_url = vim.fn.system("git -C " .. git_root .. " ls-remote --get-url origin"):gsub("\n", "")

	-- Extract the host, username, and repository name
	local host, user, repo

	if remote_url:match("^https?://") then
		-- HTTPS URL format
		host, user, repo = remote_url:match("https?://([^/]+)/([^/]+)/(.+)%.git")
	else
		-- SSH URL format
		host, user, repo = remote_url:match("git@([^:]+):([^/]+)/(.+)%.git")
	end

	if not host or not user or not repo then
		print("Unable to parse git remote URL")
		return
	end

	-- Get the current mode
	local mode = vim.api.nvim_get_mode().mode

	-- Get the line numbers for highlighting
	local start_line, end_line
	if mode == "v" or mode == "V" or mode == "" then
		-- Visual mode
		start_line = vim.fn.line("'<")
		end_line = vim.fn.line("'>")
	else
		-- Normal mode
		start_line = vim.fn.line(".")
		end_line = start_line
	end

	-- Construct the GitHub-style URL
	local github_url = string.format(
		"https://%s/%s/%s/blob/%s/%s#L%d-L%d",
		host,
		user,
		repo,
		branch,
		file_path:sub(#git_root + 2),
		start_line,
		end_line
	)

	-- Open the URL in the default browser
	local open_cmd
	if vim.fn.has("mac") == 1 then
		open_cmd = "open"
	elseif vim.fn.has("unix") == 1 then
		open_cmd = "xdg-open"
	elseif vim.fn.has("win32") == 1 then
		open_cmd = "start"
	else
		print("Unsupported operating system")
		return
	end

	vim.fn.system(open_cmd .. " " .. github_url)
end

function M.setup(opts)
	opts = opts or {}
	local keymap = opts.keymap or "<leader>go"

	-- Create a command to call the function
	vim.api.nvim_create_user_command("Ghopen", function(cmd_opts)
		-- If there's a range, set the visual selection
		if cmd_opts.range > 0 then
			vim.cmd(string.format("normal! %dGV%dG", cmd_opts.line1, cmd_opts.line2))
		end
		M.open_in_github()
	end, { range = true })

	-- Add keybindings for normal and visual modes
	vim.keymap.set("n", keymap, ":Ghopen<CR>", { noremap = true, silent = true })
	vim.keymap.set("v", keymap, ":Ghopen<CR>", { noremap = true, silent = true })
end

return M
