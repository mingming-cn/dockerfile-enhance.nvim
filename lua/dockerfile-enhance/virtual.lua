local M = {}

-- 虚拟文本命名空间
local ns_id = vim.api.nvim_create_namespace("dockerfile_enhance_virtual")

-- 生成虚拟分隔线
local function create_virtual_separator(config)
	return string.rep(config.separator_char, config.separator_length)
end

-- 显示虚拟分隔线（加在FROM行的上方）
function M.show_virtual_separators(bufnr, from_lines, config)
	if not config.enable_virtual_text then
		return
	end

	-- 清除之前的虚拟文本
	vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

	-- 在每个FROM（除第一个）上方插入虚拟分隔线
	for i = 2, #from_lines do
		local from_line = from_lines[i] - 1 -- FROM行的0索引
		local insert_line = from_line - 1 -- 上一行
		if insert_line >= 0 then
			local separator = create_virtual_separator(config)
			-- 在上一行行首插入虚拟文本
			vim.api.nvim_buf_set_extmark(bufnr, ns_id, insert_line, 0, {
				virt_text = { { separator, config.virtual_highlight_group } },
				virt_text_pos = "overlay",
				hl_mode = "combine",
			})
		end
	end
end

-- 隐藏虚拟分隔线
function M.hide_virtual_separators(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

-- 切换虚拟分隔线显示
function M.toggle_virtual_separators(bufnr, from_lines, config)
	local has_virtual = false

	-- 检查是否已有虚拟文本
	local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns_id, 0, -1, {})
	has_virtual = #marks > 0

	if has_virtual then
		M.hide_virtual_separators(bufnr)
		return false
	else
		M.show_virtual_separators(bufnr, from_lines, config)
		return true
	end
end

-- 更新虚拟分隔线（当文件内容改变时）
function M.update_virtual_separators(bufnr, from_lines, config)
	if config.enable_virtual_text then
		M.show_virtual_separators(bufnr, from_lines, config)
	end
end

return M
