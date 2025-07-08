local config = require("dockerfile-enhance.config")
local core = require("dockerfile-enhance.core")
local virtual = require("dockerfile-enhance.virtual")

local M = {}

-- 当前配置
local current_config = config.default_config

-- 创建自动命令
local function create_autocmds()
    -- 清除已存在的自动命令
    vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = {"Dockerfile*", "*.dockerfile"},
        callback = function()
            if current_config.auto_enhance then
                M.enhance_dockerfile()
            end
        end
    })
    
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = {"Dockerfile*", "*.dockerfile"},
        callback = function()
            M.refresh_virtual_separators()
        end
    })
    
    -- 监听文本变化
    vim.api.nvim_create_autocmd("TextChanged", {
        pattern = {"Dockerfile*", "*.dockerfile"},
        callback = function()
            if current_config.auto_enhance then
                M.refresh_virtual_separators()
            end
        end
    })
    
    vim.api.nvim_create_autocmd("TextChangedI", {
        pattern = {"Dockerfile*", "*.dockerfile"},
        callback = function()
            if current_config.auto_enhance then
                M.refresh_virtual_separators()
            end
        end
    })
end

-- 设置配置
function M.setup(opts)
    current_config = config.validate_config(vim.tbl_deep_extend("force", current_config, opts or {}))
    vim.g.dockerfile_enhance_config = current_config
    
    -- 创建自动命令
    create_autocmds()
    
    -- 显示设置成功信息
    vim.notify("dockerfile-enhance.nvim 已加载（虚拟文本模式）", vim.log.levels.INFO)
end

-- 显示虚拟分隔线
function M.enhance_dockerfile()
    if not core.is_dockerfile() then
        vim.notify("当前文件不是 Dockerfile", vim.log.levels.WARN)
        return
    end
    
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    
    -- 检测FROM指令
    local from_lines, from_info = core.detect_from_instructions(lines)
    
    -- 如果有多个FROM指令，显示虚拟分隔线
    if #from_lines > 1 then
        -- 显示虚拟分隔线
        virtual.show_virtual_separators(bufnr, from_lines, current_config)
        
        -- 显示信息
        local separator_count = #from_lines - 1
        vim.notify(string.format("Dockerfile 已增强，显示 %d 个虚拟分隔符", separator_count), vim.log.levels.INFO)
        
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

-- 隐藏虚拟分隔线
function M.hide_virtual_separators()
    if not core.is_dockerfile() then
        vim.notify("当前文件不是 Dockerfile", vim.log.levels.WARN)
        return
    end
    
    local bufnr = vim.api.nvim_get_current_buf()
    virtual.hide_virtual_separators(bufnr)
    vim.notify("已隐藏虚拟分隔符", vim.log.levels.INFO)
end

-- 切换虚拟分隔线显示
function M.toggle_virtual_separators()
    if not core.is_dockerfile() then
        vim.notify("当前文件不是 Dockerfile", vim.log.levels.WARN)
        return
    end
    
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local from_lines, _ = core.detect_from_instructions(lines)
    
    if #from_lines > 1 then
        local is_visible = virtual.toggle_virtual_separators(bufnr, from_lines, current_config)
        vim.notify(is_visible and "已显示虚拟分隔符" or "已隐藏虚拟分隔符", vim.log.levels.INFO)
    else
        vim.notify("未找到多个 FROM 指令", vim.log.levels.INFO)
    end
end

-- 刷新虚拟分隔线
function M.refresh_virtual_separators()
    if not core.is_dockerfile() then
        return
    end
    
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local from_lines, _ = core.detect_from_instructions(lines)
    
    if #from_lines > 1 then
        virtual.update_virtual_separators(bufnr, from_lines, current_config)
    else
        virtual.hide_virtual_separators(bufnr)
    end
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

vim.api.nvim_create_user_command("DockerfileHideSeparators", function()
    M.hide_virtual_separators()
end, {})

vim.api.nvim_create_user_command("DockerfileToggleSeparators", function()
    M.toggle_virtual_separators()
end, {})

vim.api.nvim_create_user_command("DockerfileShowInfo", function()
    M.show_from_info()
end, {})

-- 初始化时创建自动命令（使用默认配置）
create_autocmds()

return M 