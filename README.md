# dockerfile-enhance.nvim

一个 Neovim 插件，用于在 Dockerfile 中检测多个 FROM 指令并自动添加分隔线，提高多阶段构建的可读性。

## 功能特性

- 🔍 自动检测 Dockerfile 中的多个 FROM 指令
- 📏 在多个 FROM 指令之间添加可配置的分隔线
- 🎨 支持自定义分隔符字符和长度
- 🌈 高亮显示分隔线
- 🔄 支持添加/移除/切换分隔线
- 📊 显示 FROM 指令详细信息
- ⚡ 自动模式：打开 Dockerfile 时自动应用

## 安装

### 使用 packer.nvim

```lua
use {
    'mingming-cn/dockerfile-enhance.nvim',
    config = function()
        require('dockerfile-enhance').setup()
    end
}
```

### 使用 lazy.nvim

```lua
{
    'mingming-cn/dockerfile-enhance.nvim',
    config = true,
    event = { "BufReadPost Dockerfile*", "BufReadPost *.dockerfile" }
}
```

### 使用 vim-plug

```vim
Plug 'mingming-cn/dockerfile-enhance.nvim'
```

## 配置

```lua
require('dockerfile-enhance').setup({
    separator_char = "─",      -- 分隔符字符
    separator_length = 80,     -- 分隔符长度
    highlight_group = "Comment", -- 高亮组
    auto_enhance = true,       -- 是否自动增强
    enable_highlights = true,  -- 是否启用高亮
})
```

### 配置选项

| 选项 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `separator_char` | string | `"─"` | 分隔符字符 |
| `separator_length` | number | `80` | 分隔符长度 |
| `highlight_group` | string | `"Comment"` | 高亮组名称 |
| `auto_enhance` | boolean | `true` | 是否自动增强 |
| `enable_highlights` | boolean | `true` | 是否启用高亮 |

## 使用

### 命令

插件提供以下命令：

- `:DockerfileEnhance` - 为当前 Dockerfile 添加分隔线
- `:DockerfileRemoveSeparators` - 移除所有分隔线
- `:DockerfileToggleSeparators` - 切换分隔线显示
- `:DockerfileShowInfo` - 显示 FROM 指令信息

### 示例

#### 原始 Dockerfile
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

#### 增强后的 Dockerfile
```dockerfile
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

## 自动功能

- 当打开 Dockerfile 文件时，插件会自动检测并添加分隔线
- 保存文件时会重新应用高亮
- 支持的文件类型：`Dockerfile*` 和 `*.dockerfile`

## 自定义高亮

你可以自定义分隔线的高亮样式：

```lua
-- 在 colorscheme 中定义自定义高亮组
vim.api.nvim_set_hl(0, "DockerfileSeparator", {
    fg = "#ff6b6b",
    bold = true
})

-- 在插件配置中使用
require('dockerfile-enhance').setup({
    highlight_group = "DockerfileSeparator"
})
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License 
