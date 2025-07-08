local M = {}

-- 默认配置
M.default_config = {
    separator_char = "─",      -- 分隔符字符
    separator_length = 80,     -- 分隔符长度
    highlight_group = "Comment", -- 高亮组
    auto_enhance = true,       -- 是否自动增强
    enable_highlights = true,  -- 是否启用高亮
}

-- 验证配置
function M.validate_config(config)
    local validated = {}
    
    -- 验证分隔符字符
    if type(config.separator_char) == "string" and #config.separator_char > 0 then
        validated.separator_char = config.separator_char
    else
        validated.separator_char = M.default_config.separator_char
    end
    
    -- 验证分隔符长度
    if type(config.separator_length) == "number" and config.separator_length > 0 then
        validated.separator_length = config.separator_length
    else
        validated.separator_length = M.default_config.separator_length
    end
    
    -- 验证高亮组
    if type(config.highlight_group) == "string" and #config.highlight_group > 0 then
        validated.highlight_group = config.highlight_group
    else
        validated.highlight_group = M.default_config.highlight_group
    end
    
    -- 验证自动增强
    if type(config.auto_enhance) == "boolean" then
        validated.auto_enhance = config.auto_enhance
    else
        validated.auto_enhance = M.default_config.auto_enhance
    end
    
    -- 验证高亮启用
    if type(config.enable_highlights) == "boolean" then
        validated.enable_highlights = config.enable_highlights
    else
        validated.enable_highlights = M.default_config.enable_highlights
    end
    
    return validated
end

return M 