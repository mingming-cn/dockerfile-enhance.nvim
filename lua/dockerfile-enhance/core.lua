local M = {}

-- 检测FROM指令
function M.detect_from_instructions(lines)
    local from_lines = {}
    local from_info = {}
    
    for i, line in ipairs(lines) do
        -- 匹配FROM指令，支持多行和注释
        local from_match = string.match(line, "^%s*FROM%s+([^#]+)")
        if from_match then
            table.insert(from_lines, i)
            table.insert(from_info, {
                line_num = i,
                content = vim.trim(from_match),
                original_line = line
            })
        end
    end
    
    return from_lines, from_info
end

-- 生成分隔线
function M.create_separator(config)
    return string.rep(config.separator_char, config.separator_length)
end

-- 重构Dockerfile内容
function M.restructure_dockerfile(lines, from_lines, config)
    local new_lines = {}
    local last_line = 0
    
    for _, line_num in ipairs(from_lines) do
        -- 添加FROM指令之前的内容
        for i = last_line + 1, line_num - 1 do
            table.insert(new_lines, lines[i])
        end
        
        -- 如果不是第一个FROM指令，添加分隔线
        if last_line > 0 then
            table.insert(new_lines, "")
            table.insert(new_lines, M.create_separator(config))
            table.insert(new_lines, "")
        end
        
        -- 添加FROM指令
        table.insert(new_lines, lines[line_num])
        last_line = line_num
    end
    
    -- 添加剩余的代码
    for i = last_line + 1, #lines do
        table.insert(new_lines, lines[i])
    end
    
    return new_lines
end

-- 应用高亮
function M.apply_highlights(bufnr, config)
    if not config.enable_highlights then
        return
    end
    
    local ns_id = vim.api.nvim_create_namespace("dockerfile_enhance")
    
    -- 清除之前的高亮
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local separator = M.create_separator(config)
    
    for i, line in ipairs(lines) do
        if line == separator then
            vim.api.nvim_buf_add_highlight(bufnr, ns_id, config.highlight_group, i - 1, 0, -1)
        end
    end
end

-- 检查是否为Dockerfile
function M.is_dockerfile()
    local filetype = vim.bo.filetype
    local filename = vim.fn.expand("%:t")
    
    return filetype == "dockerfile" or 
           string.match(filename, "^Dockerfile") or
           string.match(filename, "%.dockerfile$")
end

-- 获取当前缓冲区的配置
function M.get_buffer_config()
    local bufnr = vim.api.nvim_get_current_buf()
    local config = vim.b[bufnr] and vim.b[bufnr].dockerfile_enhance_config
    
    if not config then
        -- 使用全局配置或默认配置
        config = vim.g.dockerfile_enhance_config or {}
    end
    
    return config
end

return M 