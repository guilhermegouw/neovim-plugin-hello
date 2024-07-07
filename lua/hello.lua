local M = {}

local function create_floating_window(contents)
	-- Determine the size of the floating window
	local width = vim.o.columns
	local height = vim.o.lines

	local win_width = math.ceil(width * 0.4)
	local win_height = math.ceil(height * 0.2)

	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	-- Create a new buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- Create the floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- Set the content of the buffer
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)

	-- Allow the window to close when <Esc> is pressed
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<Cmd>close<CR>", { noremap = true, silent = true })

	return buf, win
end

function M.say_hello()
	-- Ask for the user's name in a floating window
	local input_buf, input_win = create_floating_window({ "Enter your name:", "" })

	-- Set up the input for the user's name
	vim.api.nvim_buf_set_option(input_buf, "modifiable", true)
	vim.api.nvim_win_set_cursor(input_win, { 2, 0 }) -- Move cursor to the second line
	vim.cmd("startinsert")

	-- Function to handle the input
	local function handle_input()
		local user_name = vim.fn.getline(2)
		local greeting = { "Hello, " .. user_name .. "! How are you?" }
		vim.api.nvim_win_close(input_win, true)

		-- Show the greeting message in a new floating window
		local greeting_buf, greeting_win = create_floating_window(greeting)

		-- Close the greeting window after 3 seconds
		vim.defer_fn(function()
			vim.api.nvim_win_close(greeting_win, true)
		end, 3000)
	end

	-- Attach a key mapping to handle input
	vim.api.nvim_buf_set_keymap(
		input_buf,
		"i",
		"<CR>",
		"<Esc>:lua handle_input()<CR>",
		{ noremap = true, silent = true }
	)

	-- Create a global function to handle the input
	_G.handle_input = handle_input
end

return M
