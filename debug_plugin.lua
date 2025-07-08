-- 插件诊断脚本
-- 使用方法: nvim -l debug_plugin.lua

print("=== dockerfile-enhance.nvim 插件诊断 ===")

-- 检查插件目录
local plugin_path = vim.fn.stdpath("data") .. "/site/pack/plugins/start/dockerfile-enhance.nvim"
print("插件路径:", plugin_path)
print("插件目录存在:", vim.fn.isdirectory(plugin_path) == 1)

-- 检查 runtimepath
print("\n=== Runtime Path ===")
local rtp = vim.opt.runtimepath:get()
for i, path in ipairs(rtp) do
	if string.find(path, "dockerfile") then
		print("找到 dockerfile 相关路径:", path)
	end
end

-- 检查插件加载
print("\n=== 插件加载测试 ===")
local ok, plugin = pcall(require, "dockerfile-enhance")
if ok then
	print("✅ 插件加载成功")

	-- 检查配置
	local config = require("dockerfile-enhance.config")
	print("✅ 配置模块加载成功")
	print("默认分隔符:", config.default_config.separator_char)
	print("默认长度:", config.default_config.separator_length)

	-- 检查核心功能
	local core = require("dockerfile-enhance.core")
	print("✅ 核心模块加载成功")

	-- 测试 FROM 指令检测
	local test_lines = {
		"FROM node:18-alpine AS base",
		"WORKDIR /app",
		"FROM base AS development",
	}
	local from_lines, from_info = core.detect_from_instructions(test_lines)
	print("✅ FROM指令检测测试通过，检测到", #from_lines, "个FROM指令")
else
	print("❌ 插件加载失败:", plugin)
end

-- 检查命令
print("\n=== 命令检查 ===")
local commands = {
	"DockerfileEnhance",
	"DockerfileRemoveSeparators",
	"DockerfileToggleSeparators",
	"DockerfileShowInfo",
}

for _, cmd in ipairs(commands) do
	local exists = vim.fn.exists(":" .. cmd) == 2
	print(cmd .. ":", exists and "✅ 存在" or "❌ 不存在")
end

-- 检查自动命令
print("\n=== 自动命令检查 ===")
local autocmds = vim.api.nvim_get_autocmds({})
for _, autocmd in ipairs(autocmds) do
	if string.find(autocmd.event, "BufRead") or string.find(autocmd.event, "BufWrite") then
		print("自动命令:", autocmd.event, "->", autocmd.pattern)
	end
end

print("\n=== 诊断完成 ===")
