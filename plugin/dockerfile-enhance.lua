-- dockerfile-enhance.nvim 插件加载文件

-- 检查是否已经加载
if vim.g.dockerfile_enhance_loaded then
	return
end

-- 设置加载标志
vim.g.dockerfile_enhance_loaded = true

-- 加载插件
local ok, plugin = pcall(require, "dockerfile-enhance")
if not ok then
	vim.notify("dockerfile-enhance.nvim 加载失败", vim.log.levels.ERROR)
	return
end

-- 设置默认配置
plugin.setup()
