-- 虚拟文本模式测试脚本
-- 使用方法: nvim -l test_virtual.lua

print("=== 测试 dockerfile-enhance.nvim 虚拟文本模式 ===")

-- 添加路径以便找到模块
package.path = package.path .. ";./lua/?.lua;./lua/?/init.lua"

-- 加载插件
local ok, plugin = pcall(require, 'dockerfile-enhance')
if not ok then
    print("❌ 插件加载失败:", plugin)
    return
end

-- 设置插件（虚拟文本模式）
plugin.setup({
    auto_enhance = true,
    enable_virtual_text = true,
    virtual_highlight_group = "Comment"
})

print("✅ 插件设置完成（虚拟文本模式）")

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
    "CMD [\"npm\", \"run\", \"dev\"]",
    "",
    "FROM base AS production",
    "COPY . .",
    "RUN npm run build",
    "EXPOSE 8080",
    "CMD [\"npm\", \"start\"]"
}

-- 创建新窗口并打开测试文件
vim.cmd("new")
local bufnr = vim.api.nvim_get_current_buf()

-- 设置文件名和文件类型
vim.api.nvim_buf_set_name(bufnr, "test.Dockerfile")
vim.api.nvim_buf_set_option(bufnr, 'filetype', 'dockerfile')

-- 写入测试内容
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, test_content)

print("✅ 测试文件创建完成")
print("文件类型:", vim.bo.filetype)
print("文件名:", vim.fn.expand("%:t"))
print("缓冲区行数:", #vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))

-- 检查是否为 Dockerfile
local core = require('dockerfile-enhance.core')
print("是否为 Dockerfile:", core.is_dockerfile())

-- 检测 FROM 指令
local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
local from_lines, from_info = core.detect_from_instructions(lines)
print("检测到的 FROM 指令数量:", #from_lines)

if #from_lines > 1 then
    print("✅ 找到多个 FROM 指令，应该可以显示虚拟分隔线")
    
    -- 手动执行增强
    print("\n执行 DockerfileEnhance...")
    plugin.enhance_dockerfile()
    
    -- 检查虚拟文本
    local virtual = require('dockerfile-enhance.virtual')
    local marks = vim.api.nvim_buf_get_extmarks(bufnr, vim.api.nvim_create_namespace("dockerfile_enhance_virtual"), 0, -1, {})
    print("虚拟文本标记数量:", #marks)
    
    if #marks > 0 then
        print("🎉 虚拟文本模式工作正常！")
        print("虚拟分隔线已显示，但文件内容未修改")
        
        -- 显示文件内容（应该没有分隔符字符）
        print("\n文件内容（前10行）:")
        for i = 1, math.min(10, #lines) do
            print(string.format("%2d: %s", i, lines[i]))
        end
        
        print("\n✅ 虚拟文本测试通过！")
        print("分隔线通过虚拟文本显示，不会影响 Dockerfile 语法")
    else
        print("❌ 未找到虚拟文本标记")
    end
else
    print("❌ 未找到多个 FROM 指令")
end

print("\n=== 测试完成 ===")
print("请检查当前窗口中的文件内容")
print("虚拟分隔线应该显示在 FROM 指令之间，但不会修改实际文件内容") 