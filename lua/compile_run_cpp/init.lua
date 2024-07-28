-- lua/compile_run_cpp/init.lua

local M = {}

function M.compile_and_run_cpp()
	local filename = vim.fn.expand("%:p")
	local basename = vim.fn.expand("%:r")
	local output_file = "output.txt"
	local input_file = "input.txt"

	local valid_extensions = { "cpp", "c" }
	local valid_file = false
	for _, ext in ipairs(valid_extensions) do
		if filename:match("%." .. ext .. "$") then
			valid_file = true
			break
		end
	end

	if not valid_file then
		vim.api.nvim_err_writeln("Not a valid C++ or C file.")
		return
	end

	local input_fd = io.open(input_file, "a+")
	if input_fd == nil then
		vim.api.nvim_err_writeln("Failed to open or create input file: " .. input_file)
		return
	end
	input_fd:close()

	local output_fd = io.open(output_file, "a+")
	if output_fd == nil then
		vim.api.nvim_err_writeln("Failed to open or create output file: " .. output_file)
		return
	end
	output_fd:close()

	local input_bufnr = vim.fn.bufnr(input_file)
	if input_bufnr == 0 then
		vim.cmd("vsp " .. input_file)
	else
		vim.cmd(input_bufnr .. "wincmd w")
	end

	local output_butnr = vim.fn.bufnr(output_file)
	if output_butnr == 0 then
		vim.cmd("split " .. output_file)
	else
		vim.cmd(output_butnr .. "wincmd w")
	end

	vim.cmd("vertical resize 71%")

	local file = vim.fn.bufnr(filename)
	vim.cmd(file .. "wincmd w")

	local compile_cmd =
		string.format("g++ %s -o %s && ./%s < %s > %s", filename, basename, basename, input_file, output_file)
	vim.cmd("silent w")
	vim.cmd("silent !clear")
	vim.cmd("silent !" .. compile_cmd)
end

function M.setup()
	vim.api.nvim_create_user_command("GCompile", M.compile_and_run, {})
end
return M
