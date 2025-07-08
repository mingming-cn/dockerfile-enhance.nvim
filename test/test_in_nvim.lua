-- 在 Neovim 环境中运行的测试脚本
-- 使用方法: nvim -l test/test_in_nvim.lua

local function run_tests()
	print("开始测试 dockerfile-enhance.nvim 插件...")

	-- 测试插件加载
	local ok, plugin = pcall(require, "dockerfile-enhance")
	if not ok then
		print("❌ 插件加载失败:", plugin)
		return
	end
	print("✅ 插件加载成功")

	-- 测试配置
	local config = require("dockerfile-enhance.config")
	local default_config = config.default_config
	assert(default_config.separator_char == "─", "默认分隔符字符错误")
	assert(default_config.separator_length == 80, "默认分隔符长度错误")
	print("✅ 配置测试通过")

	-- 测试核心功能
	local core = require("dockerfile-enhance.core")

	-- 测试 FROM 指令检测
	local test_lines = {
		"FROM node:18-alpine AS base",
		"WORKDIR /app",
		"FROM base AS development",
		"RUN npm ci",
		"FROM base AS production",
		"RUN npm run build",
	}

	local from_lines, from_info = core.detect_from_instructions(test_lines)
	assert(#from_lines == 3, "应该检测到3个FROM指令")
	print("✅ FROM指令检测测试通过")

	-- 测试分隔符生成
	local test_config = {
		separator_char = "─",
		separator_length = 10,
	}
	local separator = core.create_separator(test_config)
	assert(separator == "──────────", "分隔符生成错误")
	print("✅ 分隔符生成测试通过")

	-- 测试 Dockerfile 重构
	local simple_lines = {
		"FROM node:18-alpine AS base",
		"WORKDIR /app",
		"FROM base AS development",
		"RUN npm ci",
	}

	local simple_from_lines = { 1, 3 }
	local new_lines = core.restructure_dockerfile(simple_lines, simple_from_lines, test_config)

	-- 验证重构结果
	assert(#new_lines == 7, "重构后应该有7行")
	assert(new_lines[1] == "FROM node:18-alpine AS base", "第一行应该是第一个FROM指令")
	assert(new_lines[2] == "WORKDIR /app", "第二行应该是WORKDIR指令")
	assert(new_lines[3] == "", "第三行应该是空行")
	assert(new_lines[4] == "──────────", "第四行应该是分隔符")
	assert(new_lines[5] == "", "第五行应该是空行")
	assert(new_lines[6] == "FROM base AS development", "第六行应该是第二个FROM指令")
	assert(new_lines[7] == "RUN npm ci", "第七行应该是RUN指令")
	print("✅ Dockerfile重构测试通过")

	print("🎉 所有测试通过！")
end

-- 运行测试
run_tests()

-- 退出 Neovim
vim.cmd("q!")
