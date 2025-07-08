-- LazyVim 环境测试脚本
-- 使用方法: nvim -l test_lazyvim.lua

print("=== 测试 dockerfile-enhance.nvim 在 LazyVim 中的工作状态 ===")

-- 等待 LazyVim 加载完成
vim.wait(1000)

-- 检查插件是否加载
local ok, plugin = pcall(require, 'dockerfile-enhance')
if not ok then
    print("❌ 插件加载失败:", plugin)
    print("请确保插件已添加到 LazyVim 配置中")
    return
end

print("✅ 插件加载成功")

-- 检查命令是否存在
local commands = {
    "DockerfileEnhance",
    "DockerfileRemoveSeparators", 
    "DockerfileToggleSeparators",
    "DockerfileShowInfo"
}

print("\n=== 命令检查 ===")
for _, cmd in ipairs(commands) do
    local exists = vim.fn.exists(":" .. cmd) == 2
    print(cmd .. ":", exists and "✅ 存在" or "❌ 不存在")
end

-- 创建测试文件
local test_content = {
    "FROM node:18-alpine AS base",
    "WORKDIR /app",
    "COPY package*.json ./",
    "RUN npm ci --only=production",
    "",
    "FROM base AS development",
    "RUN npm ci",
    "COPY . .",
    "CMD [\"npm\", \"run\", \"dev\"]"
}

-- 创建新缓冲区
vim.cmd("new")
local bufnr = vim.api.nvim_get_current_buf()

-- 设置文件类型和名称
vim.api.nvim_buf_set_name(bufnr, "test.Dockerfile")
vim.api.nvim_buf_set_option(bufnr, 'filetype', 'dockerfile')

-- 写入测试内容
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, test_content)

print("\n=== 文件信息 ===")
print("文件类型:", vim.bo.filetype)
print("文件名:", vim.fn.expand("%:t"))
print("缓冲区行数:", #vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))

-- 测试插件功能
print("\n=== 功能测试 ===")
plugin.enhance_dockerfile()

-- 检查结果
local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
local separator_count = 0

for i, line in ipairs(lines) do
    if string.find(line, "─") and #line >= 80 then
        separator_count = separator_count + 1
        print("找到分隔符在第", i, "行")
    end
end

print("找到", separator_count, "个分隔符")

if separator_count > 0 then
    print("🎉 插件在 LazyVim 中工作正常！")
else
    print("❌ 插件可能有问题")
end

print("\n=== 测试完成 ===")
print("请检查当前窗口中的文件内容") 