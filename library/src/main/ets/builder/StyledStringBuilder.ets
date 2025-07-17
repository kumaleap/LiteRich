/**
 * StyledString构建器
 *
 * 将解析后的HTML元素转换为StyledString对象
 *
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import { ParsedElement, RenderContext, BuildOptions, GestureStyle } from '../types/LiteRichTypes';
import { LogUtil } from '../utils/LogUtil';

// 导入鸿蒙官方类型

/**
 * 构建结果接口
 */
interface BuildResult {
  text: string;
  styles: StyleRange[];
  events: EventRange[];
}

/**
 * 样式范围接口
 */
interface StyleRange {
  start: number;
  length: number;
  spanStyle: SpanStyle;
}

/**
 * 事件范围接口
 */
interface EventRange {
  start: number;
  length: number;
  eventType: string;
  handler: () => void;
}

export class StyledStringBuilder {
  private readonly buildOptions: BuildOptions;

  constructor(options?: BuildOptions) {
    this.buildOptions = {
      mergeAdjacentStyles: true,
      optimizeWhitespace: true,
      enableStyleInheritance: true
    };

    // 手动合并选项，替代扩展运算符
    if (options) {
      if (options.mergeAdjacentStyles !== undefined) {
        this.buildOptions.mergeAdjacentStyles = options.mergeAdjacentStyles;
      }
      if (options.optimizeWhitespace !== undefined) {
        this.buildOptions.optimizeWhitespace = options.optimizeWhitespace;
      }
      if (options.enableStyleInheritance !== undefined) {
        this.buildOptions.enableStyleInheritance = options.enableStyleInheritance;
      }
    }
  }

  /**
   * 构建StyledString
   *
   * @param elements - 解析后的元素数组
   * @param context - 渲染上下文
   * @returns StyledString对象
   */
  public build(elements: ParsedElement[], context: RenderContext): StyledString {
    try {
      // 构建文本内容和样式信息
      const buildResult = this.buildTextAndStyles(elements, context);

      if (buildResult.text.length === 0) {
        return new StyledString('');
      }

      // 创建MutableStyledString用于设置样式
      const mutableStyledString = new MutableStyledString(buildResult.text);

      // 应用样式
      this.applyStyles(mutableStyledString, buildResult.styles);

      // 应用事件处理
      this.applyEventHandlers(mutableStyledString, buildResult.events);

      LogUtil.debug('StyledStringBuilder',
        `构建完成，文本长度: ${buildResult.text.length}, 样式数量: ${buildResult.styles.length}`);

      // 直接返回MutableStyledString对象
      return mutableStyledString;

    } catch (error) {
      LogUtil.error('StyledStringBuilder', `构建失败: ${JSON.stringify(error)}`);

      // 降级处理：返回纯文本
      const fallbackText = this.extractPlainText(elements);
      return new StyledString(fallbackText);
    }
  }

  /**
   * 构建文本内容和样式信息
   */
  private buildTextAndStyles(
    elements: ParsedElement[],
    context: RenderContext,
    parentStyles?: SpanStyle
  ): BuildResult {
    const result: BuildResult = {
      text: '',
      styles: [],
      events: []
    };

    for (const element of elements) {
      const elementResult = this.processElement(element, context, result.text.length, parentStyles);

      result.text += elementResult.text;

      // 手动添加数组元素，替代扩展运算符
      for (let i = 0; i < elementResult.styles.length; i++) {
        result.styles.push(elementResult.styles[i]);
      }
      for (let i = 0; i < elementResult.events.length; i++) {
        result.events.push(elementResult.events[i]);
      }
    }

    // 优化空白字符
    if (this.buildOptions.optimizeWhitespace) {
      result.text = this.optimizeWhitespace(result.text);
    }

    return result;
  }

  /**
   * 处理单个元素
   */
  private processElement(
    element: ParsedElement,
    context: RenderContext,
    currentOffset: number,
    parentStyles?: SpanStyle
  ): BuildResult {
    const result: BuildResult = {
      text: '',
      styles: [],
      events: []
    };

    switch (element.type) {
      case 'text':
        result.text = element.textContent || '';
        break;

      case 'tag':
      case 'self-closing':
        const tagResult = this.processTagElement(element, context, currentOffset, parentStyles);
        result.text = tagResult.text;

        // 手动添加数组元素，替代扩展运算符
        for (let i = 0; i < tagResult.styles.length; i++) {
          result.styles.push(tagResult.styles[i]);
        }
        for (let i = 0; i < tagResult.events.length; i++) {
          result.events.push(tagResult.events[i]);
        }
        break;

      default:
        LogUtil.warn('StyledStringBuilder', `未知元素类型: ${element.type}`);
        break;
    }

    return result;
  }

  /**
   * 处理标签元素
   */
  private processTagElement(
    element: ParsedElement,
    context: RenderContext,
    currentOffset: number,
    parentStyles?: SpanStyle
  ): BuildResult {
    const result: BuildResult = {
      text: '',
      styles: [],
      events: []
    };

    if (!element.tagName) {
      return result;
    }

    // 获取标签样式
    const spanStyles = context.styleManager.convertToSpanStyles(element);

    // 合并父级样式 - 暂时使用第一个样式作为主样式
    const mergedSpanStyle: SpanStyle | null = spanStyles.length > 0 ? spanStyles[0] : null;

    // 处理特殊标签
    switch (element.tagName.toLowerCase()) {
      case 'br':
        result.text = '\n';
        break;

      case 'hr':
        result.text = '\n---\n';
        break;

      case 'img':
        result.text = this.processImageTag(element);
        break;

      default:
      // 处理子元素
        if (element.children && element.children.length > 0) {
          const childResult = this.buildTextAndStyles(element.children, context, mergedSpanStyle || parentStyles);
          result.text = childResult.text;

          // 手动添加数组元素，替代扩展运算符
          for (let j = 0; j < childResult.styles.length; j++) {
            result.styles.push(childResult.styles[j]);
          }
          for (let j = 0; j < childResult.events.length; j++) {
            result.events.push(childResult.events[j]);
          }
        }
        break;
    }

    // 应用当前元素的样式
    // ✅ 为每个样式创建StyleRange并设置正确的位置信息
    if (result.text.length > 0 && spanStyles.length > 0) {
      for (const spanStyle of spanStyles) {
        // 创建新的SpanStyle对象，设置正确的位置信息
        const positionedSpanStyle: SpanStyle = {
          start: currentOffset,
          length: result.text.length,
          styledKey: spanStyle.styledKey,
          styledValue: spanStyle.styledValue
        };

        const styleRange: StyleRange = {
          start: currentOffset,
          length: result.text.length,
          spanStyle: positionedSpanStyle
        };
        result.styles.push(styleRange);
      }
    }

    // 处理事件
    this.processElementEvents(element, context, currentOffset, result.text.length, result.events);

    return result;
  }

  /**
   * 处理图片标签
   */
  private processImageTag(element: ParsedElement): string {
    const alt = element.attributes?.alt || '';
    const src = element.attributes?.src || '';

    if (alt) {
      return `[图片: ${alt}]`;
    } else if (src) {
      // 提取文件名作为替代文本
      const filename = src.split('/').pop()?.split('?')[0] || '';
      return filename ? `[图片: ${filename}]` : '[图片]';
    }

    return '[图片]';
  }

  /**
   * 处理元素事件
   */
  private processElementEvents(
    element: ParsedElement,
    context: RenderContext,
    startOffset: number,
    length: number,
    events: EventRange[]
  ): void {
    if (!element.tagName || length === 0) {
      return;
    }

    const tagName = element.tagName.toLowerCase();

    // 链接点击事件
    if (tagName === 'a' && element.attributes?.href) {
      const href = element.attributes.href;
      events.push({
        start: startOffset,
        length: length,
        eventType: 'click',
        handler: () => {
          if (context.eventHandlers.onLinkClick) {
            context.eventHandlers.onLinkClick(href, element);
          } else {
            // 默认行为：打开浏览器
            this.openUrl(href);
          }
        }
      });
    }

    // 图片点击事件
    if (tagName === 'img' && element.attributes?.src) {
      const src = element.attributes.src;
      events.push({
        start: startOffset,
        length: length,
        eventType: 'click',
        handler: () => {
          if (context.eventHandlers.onImageClick) {
            context.eventHandlers.onImageClick(src, element);
          }
        }
      });
    }

    // 自定义标签点击事件
    if (context.eventHandlers.onCustomTagClick) {
      events.push({
        start: startOffset,
        length: length,
        eventType: 'click',
        handler: () => {
          context.eventHandlers.onCustomTagClick!(tagName, element);
        }
      });
    }
  }

  /**
   * 应用样式到MutableStyledString
   */
  private applyStyles(mutableStyledString: MutableStyledString, styleRanges: StyleRange[]): void {
    for (const range of styleRanges) {
      try {
        // ✅ 使用官方SpanStyle格式
        const spanStyle: SpanStyle = {
          start: range.start,
          length: range.length,
          styledKey: range.spanStyle.styledKey,
          styledValue: range.spanStyle.styledValue
        };

        mutableStyledString.setStyle(spanStyle);
      } catch (error) {
        LogUtil.error('StyledStringBuilder', `应用样式失败: ${JSON.stringify(error)}`);
      }
    }
  }

  /**
   * 应用事件处理器到MutableStyledString
   */
  private applyEventHandlers(
    mutableStyledString: MutableStyledString,
    eventRanges: EventRange[]
  ): void {
    for (const range of eventRanges) {
      try {
        // ✅ 使用官方SpanStyle格式设置手势样式
        const gestureStyle: GestureStyle = {
          onClick: range.handler
        };

        const spanStyle: SpanStyle = {
          start: range.start,
          length: range.length,
          styledKey: StyledStringKey.GESTURE,
          styledValue: gestureStyle
        };

        mutableStyledString.setStyle(spanStyle);
      } catch (error) {
        LogUtil.error('StyledStringBuilder', `应用事件处理器失败: ${JSON.stringify(error)}`);
      }
    }
  }

  /**
   * 优化空白字符
   */
  private optimizeWhitespace(text: string): string {
    // 合并多个连续空格为单个空格
    return text.replace(/\s+/g, ' ').trim();
  }

  /**
   * 提取纯文本（降级处理）
   */
  private extractPlainText(elements: ParsedElement[]): string {
    let text = '';

    for (const element of elements) {
      if (element.type === 'text') {
        text += element.textContent || '';
      } else if (element.children) {
        text += this.extractPlainText(element.children);
      }
    }

    return text;
  }

  /**
   * 打开URL（默认实现）
   */
  private openUrl(url: string): void {
    LogUtil.info('StyledStringBuilder', `打开链接: ${url}`);
    // 这里可以根据需要实现具体的URL打开逻辑
    // 例如调用系统浏览器或应用内WebView
  }
}