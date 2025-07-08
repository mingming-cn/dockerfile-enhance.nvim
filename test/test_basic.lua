-- 基本功能测试
-- 添加路径以便找到模块
package.path = package.path .. ";../lua/?.lua;../lua/?/init.lua"

local function test_dockerfile_detection()
	local core = require("dockerfile-enhance.core")

	-- 测试 Dockerfile 检测
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
	assert(from_lines[1] == 1, "第一个FROM指令应该在第1行")
	assert(from_lines[2] == 3, "第二个FROM指令应该在第3行")
	assert(from_lines[3] == 5, "第三个FROM指令应该在第5行")

	print("✅ FROM指令检测测试通过")
end

local function test_separator_creation()
	local core = require("dockerfile-enhance.core")

	local config = {
		separator_char = "─",
		separator_length = 10,
	}

	local separator = core.create_separator(config)
	assert(separator == "──────────", "分隔符应该正确生成")

	print("✅ 分隔符生成测试通过")
end

local function test_dockerfile_restructure()
	local core = require("dockerfile-enhance.core")

	local test_lines = {
		"FROM node:18-alpine AS base",
		"WORKDIR /app",
		"FROM base AS development",
		"RUN npm ci",
	}

	local from_lines = { 1, 3 }
	local config = {
		separator_char = "─",
		separator_length = 10,
	}

	local new_lines = core.restructure_dockerfile(test_lines, from_lines, config)

	assert(#new_lines == 6, "重构后应该有6行")
	assert(new_lines[1] == "FROM node:18-alpine AS base", "第一行应该是第一个FROM指令")
	assert(new_lines[2] == "", "第二行应该是空行")
	assert(new_lines[3] == "──────────", "第三行应该是分隔符")
	assert(new_lines[4] == "", "第四行应该是空行")
	assert(new_lines[5] == "FROM base AS development", "第五行应该是第二个FROM指令")
	assert(new_lines[6] == "RUN npm ci", "第六行应该是剩余内容")

	print("✅ Dockerfile重构测试通过")
end

-- 运行测试
print("开始运行测试...")
test_dockerfile_detection()
test_separator_creation()
test_dockerfile_restructure()
print("所有测试通过！")
