/**
 * LiteRich库主入口文件
 * 
 * 导出所有公共API和类型定义
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import { LiteRichConfig } from './src/main/ets/config/LiteRichConfig';
import { TagStyleManager } from './src/main/ets/style/TagStyleManager';
import { LiteRichOptions } from './src/main/ets/types/LiteRichTypes';

// ✅ 主要组件导出
export { LiteRich } from './src/main/ets/LiteRich';

// ✅ 配置类导出
export { LiteRichConfig } from './src/main/ets/config/LiteRichConfig';

// ✅ 样式管理器导出
export { TagStyleManager } from './src/main/ets/style/TagStyleManager';

// ✅ 解析器导出
export { HtmlParser } from './src/main/ets/parser/HtmlParser';

// ✅ 构建器导出
export { StyledStringBuilder } from './src/main/ets/builder/StyledStringBuilder';

// ✅ 工具类导出
export { LogUtil } from './src/main/ets/utils/LogUtil';

// ✅ 类型定义导出
export type {
  // 核心类型
  LiteRichOptions,
  ParsedElement,
  RenderContext,
  EventHandlers,
  
  // 样式相关
  TagStyle,
  TextStyle,
  DecorationStyle,
  BackgroundColorStyle,
  GestureStyle,
  
  // 构建相关
  BuildOptions,

  // 解析相关
  ParseOptions,

  // 工具类型
  ElementType,
} from './src/main/ets/types/LiteRichTypes';

// ✅ 常量导出
export const LITE_RICH_VERSION: string = '1.0.0';

/**
 * 创建LiteRich实例的便捷函数
 * 
 * @param options - 配置选项
 * @returns LiteRich配置对象
 */
export function createLiteRichConfig(options?: LiteRichOptions): LiteRichConfig {
  const config = new LiteRichConfig();
  if (options) {
    config.updateConfig(options);
  }
  return config;
}

/**
 * 创建标签样式管理器的便捷函数
 * 
 * @returns TagStyleManager实例
 */
export function createTagStyleManager(): TagStyleManager {
  const manager = new TagStyleManager();
  manager.registerDefaultStyles();
  return manager;
}