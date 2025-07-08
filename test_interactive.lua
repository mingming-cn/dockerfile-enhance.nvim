-- 交互式测试脚本
-- 使用方法: nvim -l test_interactive.lua

print("=== 交互式测试 dockerfile-enhance.nvim ===")

-- 加载插件
local ok, plugin = pcall(require, "dockerfile-enhance")
if not ok then
	print("❌ 插件加载失败:", plugin)
	return
end

-- 设置插件
plugin.setup({
	auto_enhance = true,
	enable_highlights = true,
})

print("✅ 插件设置完成")

-- 创建测试内容
local test_content = {
	"FROM node:18-alpine AS base",
	"WORKDIR /app",
	"COPY package*.json ./",
	"RUN npm ci --only=production",
	"",
	"FROM base AS development",
	"RUN npm ci",
	"COPY . .",
	"EXPOSE 3000",
	'CMD ["npm", "run", "dev"]',
	"",
	"FROM base AS production",
	"COPY . .",
	"RUN npm run build",
	"EXPOSE 8080",
	'CMD ["npm", "start"]',
}

-- 创建新窗口并打开测试文件
vim.cmd("new")
local bufnr = vim.api.nvim_get_current_buf()

-- 设置文件名和文件类型
vim.api.nvim_buf_set_name(bufnr, "test.Dockerfile")
vim.api.nvim_buf_set_option(bufnr, "filetype", "dockerfile")

-- 写入测试内容
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, test_content)

print("✅ 测试文件创建完成")
print("文件类型:", vim.bo.filetype)
print("文件名:", vim.fn.expand("%:t"))
print("缓冲区行数:", #vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))

-- 检查是否为 Dockerfile
local core = require("dockerfile-enhance.core")
print("是否为 Dockerfile:", core.is_dockerfile())

-- 检测 FROM 指令
local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
local from_lines, from_info = core.detect_from_instructions(lines)
print("检测到的 FROM 指令数量:", #from_lines)

if #from_lines > 1 then
	print("✅ 找到多个 FROM 指令，应该可以添加分隔线")

	-- 手动执行增强
	print("\n执行 DockerfileEnhance...")
	plugin.enhance_dockerfile()

	-- 检查结果
	local new_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	print("增强后行数:", #new_lines)

	-- 查找分隔符
	local separator_count = 0
	for i, line in ipairs(new_lines) do
		if string.find(line, "─") and #line >= 80 then
			separator_count = separator_count + 1
			print("找到分隔符在第", i, "行")
		end
	end

	print("找到", separator_count, "个分隔符")

	if separator_count > 0 then
		print("🎉 插件工作正常！")
	else
		print("❌ 未找到分隔符，插件可能有问题")
	end
else
	print("❌ 未找到多个 FROM 指令")
end

print("\n=== 测试完成 ===")
print("请检查当前窗口中的文件内容")
print("按任意键继续...")

-- 等待用户输入
vim.fn.getchar()
