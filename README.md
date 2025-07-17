# LiteRich 富文本组件

一个高性能、高扩展性的鸿蒙ArkTS富文本渲染组件，支持HTML标签解析和自定义样式。

## 特性

- 🚀 **高性能**: 基于StyledString实现，性能优异
- 🎨 **高扩展性**: 支持自定义标签样式和事件处理
- 🔧 **灵活配置**: 丰富的配置选项，满足各种需求
- 📱 **鸿蒙原生**: 严格遵循ArkTS开发规范
- 🛡️ **安全可靠**: 内置HTML清理和安全检查
- 🎯 **易于使用**: 简洁的API设计，开箱即用

## 安装

```bash
ohpm install @ark/literich
```

## 快速开始

### 基础使用

```typescript
import { LiteRich } from '@ark/literich';

@Component
struct MyPage {
  @State htmlContent: string = `
    <h1>标题</h1>
    <p>这是一段<strong>粗体</strong>文本，包含<a href="https://example.com">链接</a>。</p>
  `;

  build() {
    Column() {
      LiteRich({
        text: this.htmlContent
      })
    }
  }
}
```

### 自定义配置

```typescript
import { LiteRich, LiteRichOptions, TagStyle, EventHandlers } from '@your-org/literich';

@Component
struct CustomPage {
  build() {
    Column() {
      LiteRich({
        text: this.htmlContent,
        options: this.createOptions()
      })
    }
  }

  private createOptions(): LiteRichOptions {
    const customStyles: Record<string, TagStyle> = {
      'h1': {
        fontSize: 24,
        fontColor: '#FF6B35',
        fontWeight: FontWeight.Bold
      },
      'a': {
        fontColor: '#00C853',
        decoration: {
          type: TextDecorationType.Underline
        }
      }
    };

    const eventHandlers: EventHandlers = {
      onLinkClick: (url: string) => {
        console.info(`点击链接: ${url}`);
      }
    };

    return {
      customStyles: customStyles,
      eventHandlers: eventHandlers,
      maxContentLength: 50000,
      debug: true
    };
  }
}
```

## 支持的HTML标签

### 文本标签
- `<h1>` - `<h6>`: 标题标签
- `<p>`: 段落
- `<strong>`, `<b>`: 粗体
- `<em>`, `<i>`: 斜体
- `<u>`: 下划线
- `<s>`, `<del>`: 删除线
- `<small>`: 小字体
- `<mark>`: 高亮
- `<code>`: 内联代码
- `<pre>`: 预格式化文本
- `<blockquote>`: 引用

### 结构标签
- `<div>`: 容器
- `<span>`: 内联容器
- `<br>`: 换行
- `<hr>`: 分割线

### 链接标签
- `<a>`: 链接（支持点击事件）

### 自定义标签
支持任意自定义标签，通过配置样式和事件处理器实现功能。

## API 文档

### LiteRich 组件参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| text | string | 是 | - | HTML内容字符串 |
| options | LiteRichOptions | 否 | - | 组件配置选项 |

### LiteRichOptions 配置

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| maxContentLength | number | 50000 | 最大内容长度 |
| textAlign | TextAlign | Start | 文本对齐方式 |
| maxLines | number | -1 | 最大行数，-1为不限制 |
| fontSize | number | 16 | 默认字体大小 |
| fontColor | string | '#333333' | 默认字体颜色 |
| lineHeight | number | 1.5 | 行高 |
| allowedTags | string[] | - | 允许的标签列表 |
| forbiddenTags | string[] | - | 禁止的标签列表 |
| customStyles | Record<string, TagStyle> | - | 自定义标签样式 |
| eventHandlers | EventHandlers | - | 事件处理器 |
| debug | boolean | false | 是否启用调试模式 |

### TagStyle 样式配置

| 属性 | 类型 | 说明 |
|------|------|------|
| fontSize | number | 字体大小 |
| fontColor | string | 字体颜色 |
| fontWeight | FontWeight | 字体粗细 |
| fontStyle | FontStyle | 字体样式 |
| backgroundColor | string | 背景颜色 |
| padding | Padding | 内边距 |
| margin | Margin | 外边距 |
| borderRadius | number | 圆角半径 |
| border | BorderOptions | 边框样式 |
| decoration | DecorationOptions | 文本装饰 |

### EventHandlers 事件处理

| 事件 | 类型 | 说明 |
|------|------|------|
| onLinkClick | (url: string, element: ParsedElement) => void | 链接点击事件 |
| onImageClick | (src: string, element: ParsedElement) => void | 图片点击事件 |
| onCustomTagClick | (tagName: string, element: ParsedElement) => void | 自定义标签点击事件 |

## 高级用法

### 自定义标签样式

```typescript
const customStyles: Record<string, TagStyle> = {
  'custom-card': {
    backgroundColor: '#F5F5F5',
    padding: 16,
    borderRadius: 8,
    border: {
      width: 1,
      color: '#E0E0E0',
      style: BorderStyle.Solid
    }
  },
  'highlight': {
    backgroundColor: '#FFEB3B',
    fontColor: '#333333',
    padding: { left: 4, right: 4 }
  }
};
```

### 事件处理

```typescript
const eventHandlers: EventHandlers = {
  onLinkClick: (url: string, element: ParsedElement) => {
    // 自定义链接处理逻辑
    if (url.startsWith('app://')) {
      // 处理应用内链接
      this.handleAppLink(url);
    } else {
      // 打开外部链接
      this.openExternalLink(url);
    }
  },
  
  onCustomTagClick: (tagName: string, element: ParsedElement) => {
    if (tagName === 'custom-button') {
      const buttonType = element.attributes?.type;
      this.handleButtonClick(buttonType);
    }
  }
};
```

### 标签过滤

```typescript
const options: LiteRichOptions = {
  // 只允许特定标签
  allowedTags: ['p', 'strong', 'em', 'a', 'br'],
  
  // 或者禁止特定标签
  forbiddenTags: ['script', 'style', 'iframe'],
  
  // 其他配置...
};
```

## 性能优化

1. **内容长度限制**: 通过 `maxContentLength` 限制内容长度，避免内存溢出
2. **缓存机制**: 内置解析结果缓存，避免重复解析
3. **懒加载**: 大内容自动降级为纯文本显示
4. **状态优化**: 使用 `@Track` 装饰器优化状态监听

## 注意事项

1. 严格遵循ArkTS语法规范，不使用解构赋值、扩展运算符等特性
2. 所有异步操作都有完善的错误处理
3. 内置HTML安全清理，防止XSS攻击
4. 支持RTL文本方向
5. 兼容无障碍功能

## 更新日志

### v1.0.0
- 初始版本发布
- 支持基础HTML标签渲染
- 支持自定义样式和事件处理
- 完整的TypeScript类型定义

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！

## 支持

如有问题，请通过以下方式联系：

- GitHub Issues: [https://github.com/kumaleap/LiteRich/issues](https://github.com/kumaleap/LiteRich/issues)
- 邮箱: [kumaleap@163.com](mailto:kumaleap@163.com)
