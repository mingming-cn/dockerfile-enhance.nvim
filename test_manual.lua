-- 手动测试脚本
-- 使用方法: nvim -l test_manual.lua

print("开始手动测试 dockerfile-enhance.nvim...")

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

-- 创建临时缓冲区
local bufnr = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(bufnr)

-- 设置文件类型
vim.api.nvim_buf_set_option(bufnr, "filetype", "dockerfile")

-- 写入测试内容
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, test_content)

print("✅ 测试缓冲区创建成功")
print("文件类型:", vim.bo.filetype)
print("缓冲区行数:", #vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))

-- 手动执行增强功能
print("\n执行 DockerfileEnhance...")
plugin.enhance_dockerfile()

-- 检查结果
local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
print("增强后行数:", #lines)

-- 查找分隔符
local separator_count = 0
for i, line in ipairs(lines) do
	if string.find(line, "─") and #line >= 80 then
		separator_count = separator_count + 1
		print("找到分隔符在第", i, "行:", line:sub(1, 20) .. "...")
	end
end

print("找到", separator_count, "个分隔符")

-- 显示前几行内容
print("\n前10行内容:")
for i = 1, math.min(10, #lines) do
	print(string.format("%2d: %s", i, lines[i]))
end

print("\n✅ 手动测试完成")
