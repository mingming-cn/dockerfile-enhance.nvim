# dockerfile-enhance.nvim 使用指南

## 🎯 虚拟文本模式

插件现在使用 **虚拟文本模式**，这意味着：
- ✅ 分隔线通过 Neovim 的虚拟文本显示
- ✅ **不会修改实际的 Dockerfile 内容**
- ✅ **不会导致 Dockerfile 语法错误**
- ✅ 分隔线只在编辑器中可见，保存文件时不会包含分隔符

## 快速测试

### 1. 启动 Neovim 并打开测试文件

```bash
# 打开测试 Dockerfile
nvim test.Dockerfile
```

### 2. 手动执行插件命令

在 Neovim 中执行以下命令：

```vim
:DockerfileEnhance
```

您应该看到：
- 通知消息："Dockerfile 已增强，显示 X 个虚拟分隔符"
- 在多个 FROM 指令之间出现虚拟分隔线
- **文件内容保持不变，没有语法错误**

### 3. 其他可用命令

```vim
:DockerfileShowInfo      " 显示所有 FROM 指令信息
:DockerfileHideSeparators  " 隐藏虚拟分隔线
:DockerfileToggleSeparators  " 切换虚拟分隔线显示
```

## 自动模式测试

### 1. 确保自动模式已启用

插件默认启用自动模式。当您打开 Dockerfile 文件时，插件会自动检测并显示虚拟分隔线。

### 2. 测试自动功能

```bash
# 打开一个多阶段构建的 Dockerfile
nvim examples/multi-stage.Dockerfile
```

插件应该自动在多个 FROM 指令之间显示虚拟分隔线。

## 虚拟文本模式的优势

### 🔒 **语法安全**
- 不会修改 Dockerfile 的实际内容
- 不会导致 Docker 构建错误
- 保存文件时不会包含分隔符字符

### 👁️ **视觉增强**
- 分隔线只在编辑器中可见
- 提高多阶段构建的可读性
- 可以随时隐藏或显示

### ⚡ **实时更新**
- 当您编辑 Dockerfile 时，分隔线会自动更新
- 支持实时检测 FROM 指令的变化

## 故障排除

### 插件没有效果？

1. **检查插件是否正确加载**：
   ```vim
   :lua print(vim.fn.exists(":DockerfileEnhance"))
   ```
   应该返回 `2`（命令存在）

2. **检查文件类型**：
   ```vim
   :set filetype?
   ```
   应该显示 `dockerfile`

3. **手动加载插件**：
   ```vim
   :lua require('dockerfile-enhance').setup()
   ```

4. **检查是否有多个 FROM 指令**：
   ```vim
   :DockerfileShowInfo
   ```

### 虚拟分隔线没有显示？

1. **检查虚拟文本设置**：
   ```vim
   :lua require('dockerfile-enhance').setup({enable_virtual_text = true})
   ```

2. **手动刷新虚拟分隔线**：
   ```vim
   :lua require('dockerfile-enhance').refresh_virtual_separators()
   ```

3. **检查 Neovim 版本**：
   虚拟文本需要 Neovim 0.6.0 或更高版本

## 配置选项

### 虚拟文本配置

```lua
require('dockerfile-enhance').setup({
    separator_char = "─",      -- 分隔符字符
    separator_length = 80,     -- 分隔符长度
    highlight_group = "Comment", -- 高亮组
    auto_enhance = true,       -- 自动增强
    enable_highlights = true,  -- 启用高亮
    enable_virtual_text = true, -- 启用虚拟文本（推荐）
    virtual_highlight_group = "Comment", -- 虚拟文本高亮组
})
```

### 自定义虚拟分隔符

```lua
require('dockerfile-enhance').setup({
    separator_char = "=",      -- 使用等号作为分隔符
    separator_length = 60,     -- 分隔符长度
    virtual_highlight_group = "Special", -- 使用特殊高亮组
})
```

### 禁用虚拟文本

```lua
require('dockerfile-enhance').setup({
    enable_virtual_text = false
})
```

## 示例效果

### 原始 Dockerfile（文件内容）
```dockerfile
FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM base AS development
RUN npm ci
COPY . .
CMD ["npm", "run", "dev"]

FROM base AS production
COPY . .
RUN npm run build
CMD ["npm", "start"]
```

### 编辑器中的显示效果
```
FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
────────────────────────────────────────────────────────────────────────────────
FROM base AS development
RUN npm ci
COPY . .
CMD ["npm", "run", "dev"]
────────────────────────────────────────────────────────────────────────────────
FROM base AS production
COPY . .
RUN npm run build
CMD ["npm", "start"]
```

**注意**：分隔线只在编辑器中显示，保存文件时仍然是原始的 Dockerfile 内容。

## 调试信息

如果遇到问题，可以运行诊断脚本：

```bash
nvim -l debug_plugin.lua
```

或者运行虚拟文本测试：

```bash
nvim -l test_virtual.lua
```

## 技术说明

插件使用 Neovim 的 `extmark` API 来显示虚拟文本：
- 虚拟文本不会影响文件的实际内容
- 分隔线显示在 FROM 指令行的末尾
- 支持自定义高亮和样式
- 实时响应文件内容变化 