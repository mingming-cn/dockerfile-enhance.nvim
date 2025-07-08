# dockerfile-enhance.nvim 在 LazyVim 中的设置

## 问题诊断

您使用的是 LazyVim 配置，它有自己的插件管理系统。之前的设置没有效果是因为 LazyVim 不会自动加载本地插件目录中的插件。

## 解决方案

### 1. 插件配置已添加

我已经为您在 LazyVim 配置中添加了插件：
- 文件位置：`~/.config/nvim/lua/plugins/dockerfile-enhance.lua`
- 插件路径：指向您的开发目录 `/Users/ming/lua/dockerfile-enhance.nvim`

### 2. 重新启动 Neovim

```bash
# 完全退出 Neovim
# 然后重新启动
nvim
```

### 3. 同步插件

在 Neovim 中执行：
```vim
:Lazy sync
```

### 4. 测试插件

打开一个 Dockerfile 文件：
```bash
nvim test.Dockerfile
```

然后执行：
```vim
:DockerfileEnhance
```

## 验证插件是否工作

### 方法1：检查命令
```vim
:lua print(vim.fn.exists(":DockerfileEnhance"))
```
应该返回 `2`

### 方法2：运行测试脚本
```bash
nvim -l test_lazyvim.lua
```

### 方法3：检查插件状态
```vim
:Lazy
```
在插件列表中应该能看到 `dockerfile-enhance.nvim`

## 如果仍然没有效果

### 1. 检查 LazyVim 日志
```vim
:Lazy log
```

### 2. 手动加载插件
```vim
:lua require('dockerfile-enhance').setup()
```

### 3. 检查文件类型
```vim
:set filetype?
```
应该显示 `dockerfile`

### 4. 检查 FROM 指令
```vim
:DockerfileShowInfo
```

## 配置选项

您可以在 `~/.config/nvim/lua/plugins/dockerfile-enhance.lua` 中修改配置：

```lua
return {
  "dockerfile-enhance.nvim",
  dir = "/Users/ming/lua/dockerfile-enhance.nvim",
  event = { "BufReadPost Dockerfile*", "BufReadPost *.dockerfile" },
  config = function()
    require("dockerfile-enhance").setup({
      separator_char = "─",      -- 分隔符字符
      separator_length = 80,     -- 分隔符长度
      highlight_group = "Comment", -- 高亮组
      auto_enhance = true,       -- 自动增强
      enable_highlights = true,  -- 启用高亮
    })
  end,
}
```

## 开发模式

如果您想实时测试代码修改，可以：

1. 修改插件代码
2. 在 Neovim 中执行：`:Lazy reload dockerfile-enhance.nvim`
3. 测试功能

## 故障排除

如果插件仍然不工作，请检查：

1. **LazyVim 是否正确加载**：
   ```vim
   :Lazy
   ```

2. **插件是否在列表中**：
   在 LazyVim 界面中查找 `dockerfile-enhance.nvim`

3. **插件路径是否正确**：
   确认 `/Users/ming/lua/dockerfile-enhance.nvim` 目录存在

4. **文件权限**：
   确保插件目录有正确的读取权限 
