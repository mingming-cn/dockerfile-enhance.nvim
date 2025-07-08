local config = require("dockerfile-enhance.config")
local core = require("dockerfile-enhance.core")

local M = {}

-- 当前配置
local current_config = config.default_config

-- 设置配置
function M.setup(opts)
    current_config = config.validate_config(vim.tbl_deep_extend("force", current_config, opts or {}))
    vim.g.dockerfile_enhance_config = current_config
end

-- 检测并添加分隔线
function M.enhance_dockerfile()
    if not core.is_dockerfile() then
        vim.notify("当前文件不是 Dockerfile", vim.log.levels.WARN)
        return
    end
    
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    
    -- 检测FROM指令
    local from_lines, from_info = core.detect_from_instructions(lines)
    
    -- 如果有多个FROM指令，在它们之间添加分隔线
    if #from_lines > 1 then
        -- 重构Dockerfile内容
        local new_lines = core.restructure_dockerfile(lines, from_lines, current_config)
        
        -- 更新缓冲区
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
        
        -- 应用高亮
        core.apply_highlights(bufnr, current_config)
        
        -- 显示信息
        local separator_count = #from_lines - 1
        vim.notify(string.format("Dockerfile 已增强，添加了 %d 个分隔符", separator_count), vim.log.levels.INFO)
        
        -- 显示FROM指令信息
        local info_msg = "检测到的 FROM 指令:\n"
        for i, info in ipairs(from_info) do
            info_msg = info_msg .. string.format("  %d. %s\n", i, info.content)
        end
        vim.notify(info_msg, vim.log.levels.INFO)
    else
        vim.notify("未找到多个 FROM 指令", vim.log.levels.INFO)
    end
end

-- 移除分隔线
function M.remove_separators()
    if not core.is_dockerfile() then
        vim.notify("当前文件不是 Dockerfile", vim.log.levels.WARN)
        return
    end
    
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local separator = core.create_separator(current_config)
    
    local new_lines = {}
    local removed_count = 0
    
    for i, line in ipairs(lines) do
        if line ~= separator and line ~= "" then
            table.insert(new_lines, line)
        elseif line == separator then
            removed_count = removed_count + 1
        end
    end
    
    -- 更新缓冲区
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
    
    -- 清除高亮
    local ns_id = vim.api.nvim_create_namespace("dockerfile_enhance")
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    
    vim.notify(string.format("已移除 %d 个分隔符", removed_count), vim.log.levels.INFO)
end

-- 切换分隔线显示
function M.toggle_separators()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local separator = core.create_separator(current_config)
    
    -- 检查是否已有分隔线
    local has_separators = false
    for _, line in ipairs(lines) do
        if line == separator then
            has_separators = true
            break
        end
    end
    
    if has_separators then
        M.remove_separators()
    else
        M.enhance_dockerfile()
    end
end

-- 重新应用高亮
function M.refresh_highlights()
    if not core.is_dockerfile() then
        return
    end
    
    local bufnr = vim.api.nvim_get_current_buf()
    core.apply_highlights(bufnr, current_config)
end

-- 显示FROM指令信息
function M.show_from_info()
    if not core.is_dockerfile() then
        vim.notify("当前文件不是 Dockerfile", vim.log.levels.WARN)
        return
    end
    
    local lines = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false)
    local from_lines, from_info = core.detect_from_instructions(lines)
    
    if #from_info == 0 then
        vim.notify("未找到 FROM 指令", vim.log.levels.INFO)
        return
    end
    
    local info_msg = string.format("找到 %d 个 FROM 指令:\n", #from_info)
    for i, info in ipairs(from_info) do
        info_msg = info_msg .. string.format("  %d. 第%d行: %s\n", i, info.line_num, info.content)
    end
    
    vim.notify(info_msg, vim.log.levels.INFO)
end

-- 创建命令
vim.api.nvim_create_user_command("DockerfileEnhance", function()
    M.enhance_dockerfile()
end, {})

vim.api.nvim_create_user_command("DockerfileRemoveSeparators", function()
    M.remove_separators()
end, {})

vim.api.nvim_create_user_command("DockerfileToggleSeparators", function()
    M.toggle_separators()
end, {})

vim.api.nvim_create_user_command("DockerfileShowInfo", function()
    M.show_from_info()
end, {})

-- 自动命令
if current_config.auto_enhance then
    vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = {"Dockerfile*", "*.dockerfile"},
        callback = function()
            M.enhance_dockerfile()
        end
    })
    
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = {"Dockerfile*", "*.dockerfile"},
        callback = function()
            M.refresh_highlights()
        end
    })
end

return M 