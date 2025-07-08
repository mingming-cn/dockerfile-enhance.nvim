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

-- 生成分隔线（用于虚拟文本）
function M.create_separator(config)
    return string.rep(config.separator_char, config.separator_length)
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

-- 检查是否有多个FROM指令
function M.has_multiple_from_instructions(lines)
    local from_lines, _ = M.detect_from_instructions(lines)
    return #from_lines > 1
end

-- 获取FROM指令之间的行号
function M.get_from_separator_positions(from_lines)
    local positions = {}
    
    for i = 2, #from_lines do
        local prev_line = from_lines[i-1]
        local current_line = from_lines[i]
        
        -- 在上一行的末尾位置添加分隔符
        table.insert(positions, {
            line = prev_line,
            col = 0  -- 将在虚拟文本中处理列位置
        })
    end
    
    return positions
end

return M 