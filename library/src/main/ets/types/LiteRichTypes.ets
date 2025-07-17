/**
 * LiteRich类型定义
 * 
 * 定义组件所需的所有类型接口
 * 
 * @since 1.0.0
 */

import { LiteRichConfig } from "../config/LiteRichConfig";
import { TagStyleManager } from "../style/TagStyleManager";

/**
 * LiteRich组件配置选项
 */
export interface LiteRichOptions {
  /** 最大内容长度限制 */
  maxContentLength?: number;
  
  /** 文本对齐方式 */
  textAlign?: TextAlign;
  
  /** 最大行数 */
  maxLines?: number;
  
  /** 文本溢出处理 */
  textOverflow?: TextOverflowOptions;
  
  /** 行高 */
  lineHeight?: number | string | Resource;
  
  /** 字体大小 */
  fontSize?: number | string | Resource;
  
  /** 字体颜色 */
  fontColor?: ResourceColor;
  
  /** 字体族 */
  fontFamily?: string | Resource;
  
  /** 自定义标签样式 */
  customStyles?: Record<string, TagStyle>;
  
  /** 事件处理器 */
  eventHandlers?: EventHandlers;
  
  /** 允许的标签白名单 */
  allowedTags?: string[];
  
  /** 禁用的标签黑名单 */
  disallowedTags?: string[];
  
  /** 是否启用调试模式 */
  debug?: boolean;
}

/**
 * 标签样式定义
 */
export interface TagStyle {
  /** 字体大小 */
  fontSize?: number | string | Resource;
  
  /** 字体颜色 */
  fontColor?: ResourceColor;
  
  /** 字体族 */
  fontFamily?: string | Resource;
  
  /** 字体粗细 */
  fontWeight?: number | FontWeight | string;
  
  /** 字体样式 */
  fontStyle?: FontStyle;
  
  /** 文本装饰 */
  decoration?: DecorationStyle;
  
  /** 背景颜色 */
  backgroundColor?: ResourceColor;
  
  /** 基线偏移 */
  baselineOffset?: number;
  
  /** 边距 */
  margin?: Margin | Length;
  
  /** 内边距 */
  padding?: Padding | Length;
  
  /** 边框 */
  border?: BorderOptions;
  
  /** 圆角 */
  borderRadius?: BorderRadiuses | Length;
  
  /** 阴影 */
  shadow?: ShadowOptions | ShadowStyle;
  
  /** 自定义样式处理函数 */
  customStyleHandler?: (element: ParsedElement, context: RenderContext) => StyledStringKey[];
}

/**
 * 解析后的HTML元素
 */
export interface ParsedElement {
  /** 元素类型 */
  type: ElementType;
  
  /** 标签名 */
  tagName?: string;
  
  /** 文本内容 */
  textContent?: string;
  
  /** 属性 */
  attributes?: Record<string, string>;
  
  /** 子元素 */
  children?: ParsedElement[];
  
  /** 开始位置 */
  startIndex?: number;
  
  /** 结束位置 */
  endIndex?: number;
}

/**
 * 元素类型枚举
 */
export const enum ElementType {
  TEXT = 'text',
  TAG = 'tag',
  SELF_CLOSING = 'self-closing'
}

/**
 * 渲染上下文
 */
export interface RenderContext {
  /** 配置对象 */
  config: LiteRichConfig;
  
  /** 样式管理器 */
  styleManager: TagStyleManager;
  
  /** 事件处理器 */
  eventHandlers: EventHandlers;
  
  /** 当前渲染深度 */
  depth?: number;
  
  /** 父级样式 */
  parentStyles?: StyledStringKey[];
}

/**
 * 事件处理器
 */
export interface EventHandlers {
  /** 链接点击事件 */
  onLinkClick?: (url: string, element: ParsedElement) => void;
  
  /** 图片点击事件 */
  onImageClick?: (src: string, element: ParsedElement) => void;
  
  /** 自定义标签点击事件 */
  onCustomTagClick?: (tagName: string, element: ParsedElement) => void;
  
  /** 长按事件 */
  onLongPress?: (element: ParsedElement) => void;
  
  /** 双击事件 */
  onDoubleClick?: (element: ParsedElement) => void;
}

// StyledStringKey 使用鸿蒙官方提供的枚举，不需要自定义

/**
 * 文本样式接口
 */
export interface TextStyle {
  fontSize?: number | Resource | string;
  fontColor?: ResourceColor;
  fontWeight?: number | FontWeight | string;
  fontStyle?: FontStyle;
  fontFamily?: string | Resource;
}

/**
 * 装饰样式接口
 */
export interface DecorationStyle {
  type: TextDecorationType;
  color?: ResourceColor;
  style?: TextDecorationStyle;
}

/**
 * 背景颜色样式接口
 */
export interface BackgroundColorStyle {
  color: ResourceColor;
}

/**
 * 手势样式接口
 */
export interface GestureStyle {
  onClick?: () => void;
  onLongPress?: () => void;
  onDoubleClick?: () => void;
}

// SpanStyle 使用鸿蒙官方提供的接口，不需要自定义

/**
 * 解析选项
 */
export interface ParseOptions {
  /** 是否保留空白字符 */
  preserveWhitespace?: boolean;
  
  /** 是否转换实体字符 */
  decodeEntities?: boolean;
  
  /** 是否忽略注释 */
  ignoreComments?: boolean;
  
  /** 是否忽略脚本标签 */
  ignoreScripts?: boolean;
  
  /** 是否忽略样式标签 */
  ignoreStyles?: boolean;
}

/**
 * 构建选项
 */
export interface BuildOptions {
  /** 是否合并相邻的相同样式 */
  mergeAdjacentStyles?: boolean;
  
  /** 是否优化空白字符 */
  optimizeWhitespace?: boolean;
  
  /** 是否启用样式继承 */
  enableStyleInheritance?: boolean;
}

/**
 * 错误信息
 */
export interface LiteRichError {
  /** 错误代码 */
  code: string;
  
  /** 错误消息 */
  message: string;
  
  /** 错误位置 */
  position?: number;
  
  /** 原始错误 */
  originalError?: Error;
}
