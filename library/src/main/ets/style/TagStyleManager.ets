/**
 * 标签样式管理器
 *
 * 管理HTML标签的样式映射和自定义样式
 *
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import type {
  TagStyle,
  ParsedElement,
  TextStyle,
  DecorationStyle,
  BackgroundColorStyle
} from '../types/LiteRichTypes';
import { LogUtil } from '../utils/LogUtil';

/**
 * 边距配置接口
 */
interface MarginConfig {
  top?: number;
  bottom?: number;
  left?: number;
  right?: number;
}

/**
 * 内边距配置接口
 */
interface PaddingConfig {
  top?: number;
  bottom?: number;
  left?: number;
  right?: number;
}


/**
 * 边框配置接口
 */
interface BorderConfig {
  width: number;
  color: string;
  style: BorderStyle;
}

export class TagStyleManager {
  private readonly tagStyles: Map<string, TagStyle> = new Map();

  constructor() {
    this.registerDefaultStyles();
  }

  /**
   * 注册默认标签样式
   */
  registerDefaultStyles(): void {
    // ✅ 标题标签样式
    const h1Margin: MarginConfig = { top: 16, bottom: 8 };
    this.registerTagStyle('h1', {
      fontSize: 24,
      fontWeight: FontWeight.Bold,
      fontColor: '#1a1a1a',
      margin: h1Margin
    });

    const h2Margin: MarginConfig = { top: 14, bottom: 6 };
    this.registerTagStyle('h2', {
      fontSize: 20,
      fontWeight: FontWeight.Bold,
      fontColor: '#1a1a1a',
      margin: h2Margin
    });

    const h3Margin: MarginConfig = { top: 12, bottom: 4 };
    this.registerTagStyle('h3', {
      fontSize: 18,
      fontWeight: FontWeight.Bold,
      fontColor: '#1a1a1a',
      margin: h3Margin
    });

    const h4Margin: MarginConfig = { top: 10, bottom: 4 };
    this.registerTagStyle('h4', {
      fontSize: 16,
      fontWeight: FontWeight.Bold,
      fontColor: '#1a1a1a',
      margin: h4Margin
    });

    const h5Margin: MarginConfig = { top: 8, bottom: 2 };
    this.registerTagStyle('h5', {
      fontSize: 14,
      fontWeight: FontWeight.Bold,
      fontColor: '#1a1a1a',
      margin: h5Margin
    });

    const h6Margin: MarginConfig = { top: 6, bottom: 2 };
    this.registerTagStyle('h6', {
      fontSize: 12,
      fontWeight: FontWeight.Bold,
      fontColor: '#1a1a1a',
      margin: h6Margin
    });

    // ✅ 文本样式标签
    this.registerTagStyle('strong', {
      fontWeight: FontWeight.Bold
    });
    this.registerTagStyle('b', {
      fontWeight: FontWeight.Bold
    });

    this.registerTagStyle('em', {
      fontStyle: FontStyle.Italic
    });
    this.registerTagStyle('i', {
      fontStyle: FontStyle.Italic
    });

    this.registerTagStyle('u', {
      decoration: {
        type: TextDecorationType.Underline,
        color: '#333333'
      }
    });
    this.registerTagStyle('s', {
      decoration: {
        type: TextDecorationType.LineThrough,
        color: '#666666'
      }
    });

    this.registerTagStyle('del', {
      decoration: {
        type: TextDecorationType.LineThrough,
        color: '#666666'
      }
    });

    // 大字体样式
    const bigStyle: TagStyle = {
      fontSize: 18
    };
    this.registerTagStyle('big', bigStyle);

    // 上标样式
    const supStyle: TagStyle = {
      fontSize: 10,
      baselineOffset: 5
    };
    this.registerTagStyle('sup', supStyle);

    // 下标样式
    const subStyle: TagStyle = {
      fontSize: 10,
      baselineOffset: -5
    };
    this.registerTagStyle('sub', subStyle);

    // ✅ 链接样式
    this.registerTagStyle('a', {
      fontColor: '#007AFF',
      decoration: {
        type: TextDecorationType.Underline,
        color: '#007AFF'
      }
    });

    // ✅ 段落样式
    const paragraphMargin: MarginConfig = { top: 8, bottom: 8 };
    this.registerTagStyle('p', {
      margin: paragraphMargin
    });

    // ✅ 代码样式
    const codePadding: PaddingConfig = {
      left: 4,
      right: 4,
      top: 2,
      bottom: 2
    };
    this.registerTagStyle('code', {
      fontSize: 14,
      fontColor: '#d63384',
      backgroundColor: '#f8f9fa',
      padding: codePadding,
      borderRadius: 4
    });

    const preMargin: MarginConfig = { top: 8, bottom: 8 };
    this.registerTagStyle('pre', {
      fontSize: 14,
      fontColor: '#333333',
      backgroundColor: '#f8f9fa',
      padding: 12,
      borderRadius: 6,
      margin: preMargin
    });

    // ✅ 引用样式
    const blockquotePadding: PaddingConfig = { left: 16, top: 8, bottom: 8 };
    const blockquoteMargin: MarginConfig = { top: 8, bottom: 8 };
    const blockquoteBorder: BorderConfig = {
      width: 4, color: '#007AFF', style: BorderStyle.Solid
    };
    this.registerTagStyle('blockquote', {
      fontColor: '#666666',
      fontStyle: FontStyle.Italic,
      padding: blockquotePadding,
      margin: blockquoteMargin,
      border: blockquoteBorder
    });

    // ✅ 小字体样式
    this.registerTagStyle('small', {
      fontSize: 12,
      fontColor: '#666666'
    });

    // ✅ 标记样式
    const markPadding: PaddingConfig = { left: 2, right: 2 };
    this.registerTagStyle('mark', {
      backgroundColor: '#ffeb3b',
      padding: markPadding
    });
  }

  /**
   * 注册标签样式
   *
   * @param tagName - 标签名
   * @param style - 样式定义
   */
  public registerTagStyle(tagName: string, style: TagStyle): void {
    const normalizedTag: string = tagName.toLowerCase();
    this.tagStyles.set(normalizedTag, style);

    if (LogUtil.isDebugEnabled()) {
      LogUtil.debug('TagStyleManager', `注册标签样式: ${normalizedTag}`, JSON.stringify(style));
    }
  }

  /**
   * 获取标签样式
   *
   * @param tagName - 标签名
   * @returns 标签样式或undefined
   */
  public getTagStyle(tagName: string): TagStyle | undefined {
    const normalizedTag: string = tagName.toLowerCase();
    return this.tagStyles.get(normalizedTag);
  }

  /**
   * 移除标签样式
   *
   * @param tagName - 标签名
   */
  public removeTagStyle(tagName: string): void {
    const normalizedTag: string = tagName.toLowerCase();
    this.tagStyles.delete(normalizedTag);
  }

  /**
   * 检查标签是否有样式定义
   *
   * @param tagName - 标签名
   * @returns 是否有样式定义
   */
  public hasTagStyle(tagName: string): boolean {
    const normalizedTag: string = tagName.toLowerCase();
    return this.tagStyles.has(normalizedTag);
  }

  /**
   * 将TagStyle转换为SpanStyle数组
   *
   * @param element - 解析的元素
   * @param context - 渲染上下文
   * @returns SpanStyle数组（不包含位置信息，需要后续设置）
   */
  public convertToSpanStyles(
    element: ParsedElement
  ): SpanStyle[] {
    const spanStyles: SpanStyle[] = [];

    if (!element.tagName) {
      return spanStyles;
    }

    const tagStyle: TagStyle | undefined = this.getTagStyle(element.tagName);
    if (!tagStyle) {
      return spanStyles;
    }

    // ✅ 字体样式
    const fontStyle: TextStyle = {};

    if (tagStyle.fontSize !== undefined) {
      fontStyle.fontSize = tagStyle.fontSize;
    }

    if (tagStyle.fontColor !== undefined) {
      fontStyle.fontColor = tagStyle.fontColor;
    }

    if (tagStyle.fontWeight !== undefined) {
      fontStyle.fontWeight = tagStyle.fontWeight;
    }

    if (tagStyle.fontStyle !== undefined) {
      fontStyle.fontStyle = tagStyle.fontStyle;
    }

    if (tagStyle.fontFamily !== undefined) {
      fontStyle.fontFamily = tagStyle.fontFamily;
    }

    // 检查是否有字体样式需要应用
    const hasFontStyles = fontStyle.fontSize || fontStyle.fontColor ||
    fontStyle.fontWeight || fontStyle.fontStyle || fontStyle.fontFamily;

    if (hasFontStyles) {
      spanStyles.push({
        start: 0, // 占位符，实际使用时会被设置
        length: 0, // 占位符，实际使用时会被设置
        styledKey: StyledStringKey.FONT,
        styledValue: fontStyle
      });
    }

    // ✅ 文本装饰
    if (tagStyle.decoration !== undefined) {
      const decorationStyle: DecorationStyle = {
        type: tagStyle.decoration.type,
        color: tagStyle.decoration.color,
        style: tagStyle.decoration.style
      };

      spanStyles.push({
        start: 0, // 占位符，实际使用时会被设置
        length: 0, // 占位符，实际使用时会被设置
        styledKey: StyledStringKey.DECORATION,
        styledValue: decorationStyle
      });
    }

    // ✅ 背景颜色
    if (tagStyle.backgroundColor !== undefined) {
      const backgroundColorStyle: BackgroundColorStyle = {
        color: tagStyle.backgroundColor
      };

      spanStyles.push({
        start: 0, // 占位符，实际使用时会被设置
        length: 0, // 占位符，实际使用时会被设置
        styledKey: StyledStringKey.BACKGROUND_COLOR,
        styledValue: backgroundColorStyle
      });
    }

    return spanStyles;
  }

  /**
   * 清理所有样式
   */
  public clear(): void {
    this.tagStyles.clear();
  }

  /**
   * 获取所有注册的标签名
   *
   * @returns 标签名数组
   */
  public getAllTagNames(): string[] {
    return Array.from(this.tagStyles.keys());
  }
}