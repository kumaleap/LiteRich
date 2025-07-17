/**
 * LiteRich配置管理器
 * 
 * 管理组件的全局配置和默认值
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import type { LiteRichOptions } from '../types/LiteRichTypes';

export class LiteRichConfig {
  // ✅ 默认配置值
  public maxContentLength: number = 50000;
  public textAlign: TextAlign = TextAlign.Start;
  public maxLines: number = -1; // 无限制
  public textOverflow: TextOverflowOptions = { overflow: TextOverflow.Ellipsis };
  public lineHeight: number | string | Resource = 1.4;
  public fontSize: number | string | Resource = 16;
  public fontColor: ResourceColor = '#333333';
  public fontFamily: string | Resource = 'HarmonyOS Sans';
  public debug: boolean = false;
  
  // ✅ 解析相关配置
  public preserveWhitespace: boolean = false;
  public decodeEntities: boolean = true;
  public ignoreComments: boolean = true;
  public ignoreScripts: boolean = true;
  public ignoreStyles: boolean = true;
  
  // ✅ 构建相关配置
  public mergeAdjacentStyles: boolean = true;
  public optimizeWhitespace: boolean = true;
  public enableStyleInheritance: boolean = true;
  
  // ✅ 标签白名单（默认支持的标签）
  public readonly defaultAllowedTags: string[] = [
    'p', 'div', 'span', 'a', 'strong', 'b', 'em', 'i', 'u', 's', 'del',
    'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'br', 'hr',
    'ul', 'ol', 'li', 'blockquote', 'pre', 'code',
    'img', 'video', 'audio', 'table', 'tr', 'td', 'th',
    'thead', 'tbody', 'tfoot', 'caption'
  ];
  
  public allowedTags: string[] = [];
  public disallowedTags: string[] = ['script', 'style', 'iframe', 'object', 'embed'];
  
  constructor() {
    // 手动复制数组，替代扩展运算符
    this.allowedTags = [];
    for (let i = 0; i < this.defaultAllowedTags.length; i++) {
      this.allowedTags.push(this.defaultAllowedTags[i]);
    }
  }
  
  /**
   * 更新配置
   * 
   * @param options - 新的配置选项
   */
  public updateConfig(options: LiteRichOptions): void {
    if (options.maxContentLength !== undefined) {
      this.maxContentLength = Math.max(1000, options.maxContentLength);
    }
    
    if (options.textAlign !== undefined) {
      this.textAlign = options.textAlign;
    }
    
    if (options.maxLines !== undefined) {
      this.maxLines = options.maxLines;
    }
    
    if (options.textOverflow !== undefined) {
      this.textOverflow = options.textOverflow;
    }
    
    if (options.lineHeight !== undefined) {
      this.lineHeight = options.lineHeight;
    }
    
    if (options.fontSize !== undefined) {
      this.fontSize = options.fontSize;
    }
    
    if (options.fontColor !== undefined) {
      this.fontColor = options.fontColor;
    }
    
    if (options.fontFamily !== undefined) {
      this.fontFamily = options.fontFamily;
    }
    
    if (options.debug !== undefined) {
      this.debug = options.debug;
    }
    
    if (options.allowedTags !== undefined) {
      this.allowedTags = [];
      for (let i = 0; i < options.allowedTags.length; i++) {
        this.allowedTags.push(options.allowedTags[i]);
      }
    }
    
    if (options.disallowedTags !== undefined) {
      this.disallowedTags = [];
      for (let i = 0; i < options.disallowedTags.length; i++) {
        this.disallowedTags.push(options.disallowedTags[i]);
      }
    }
  }
  
  /**
   * 检查标签是否被允许
   * 
   * @param tagName - 标签名
   * @returns 是否允许
   */
  public isTagAllowed(tagName: string): boolean {
    const normalizedTag: string = tagName.toLowerCase();
    
    // 检查黑名单
    if (this.disallowedTags.includes(normalizedTag)) {
      return false;
    }
    
    // 检查白名单
    return this.allowedTags.includes(normalizedTag);
  }
  
  /**
   * 添加允许的标签
   * 
   * @param tagName - 标签名
   */
  public addAllowedTag(tagName: string): void {
    const normalizedTag: string = tagName.toLowerCase();
    if (!this.allowedTags.includes(normalizedTag)) {
      this.allowedTags.push(normalizedTag);
    }
  }
  
  /**
   * 移除允许的标签
   * 
   * @param tagName - 标签名
   */
  public removeAllowedTag(tagName: string): void {
    const normalizedTag: string = tagName.toLowerCase();
    const index: number = this.allowedTags.indexOf(normalizedTag);
    if (index > -1) {
      this.allowedTags.splice(index, 1);
    }
  }
  
  /**
   * 添加禁用的标签
   * 
   * @param tagName - 标签名
   */
  public addDisallowedTag(tagName: string): void {
    const normalizedTag: string = tagName.toLowerCase();
    if (!this.disallowedTags.includes(normalizedTag)) {
      this.disallowedTags.push(normalizedTag);
    }
  }
  
  /**
   * 移除禁用的标签
   * 
   * @param tagName - 标签名
   */
  public removeDisallowedTag(tagName: string): void {
    const normalizedTag: string = tagName.toLowerCase();
    const index: number = this.disallowedTags.indexOf(normalizedTag);
    if (index > -1) {
      this.disallowedTags.splice(index, 1);
    }
  }
  
  /**
   * 重置为默认配置
   */
  public resetToDefault(): void {
    this.maxContentLength = 50000;
    this.textAlign = TextAlign.Start;
    this.maxLines = -1;
    this.textOverflow = { overflow: TextOverflow.Ellipsis };
    this.lineHeight = 1.4;
    this.fontSize = 16;
    this.fontColor = '#333333';
    this.fontFamily = 'HarmonyOS Sans';
    this.debug = false;
    
    this.preserveWhitespace = false;
    this.decodeEntities = true;
    this.ignoreComments = true;
    this.ignoreScripts = true;
    this.ignoreStyles = true;
    
    this.mergeAdjacentStyles = true;
    this.optimizeWhitespace = true;
    this.enableStyleInheritance = true;
    
    this.allowedTags = [];
    for (let i = 0; i < this.defaultAllowedTags.length; i++) {
      this.allowedTags.push(this.defaultAllowedTags[i]);
    }
    this.disallowedTags = ['script', 'style', 'iframe', 'object', 'embed'];
  }
  
  /**
   * 获取配置的副本
   * 
   * @returns 配置副本
   */
  public clone(): LiteRichConfig {
    const cloned: LiteRichConfig = new LiteRichConfig();
    
    cloned.maxContentLength = this.maxContentLength;
    cloned.textAlign = this.textAlign;
    cloned.maxLines = this.maxLines;
    cloned.textOverflow = this.textOverflow;
    cloned.lineHeight = this.lineHeight;
    cloned.fontSize = this.fontSize;
    cloned.fontColor = this.fontColor;
    cloned.fontFamily = this.fontFamily;
    cloned.debug = this.debug;
    
    cloned.preserveWhitespace = this.preserveWhitespace;
    cloned.decodeEntities = this.decodeEntities;
    cloned.ignoreComments = this.ignoreComments;
    cloned.ignoreScripts = this.ignoreScripts;
    cloned.ignoreStyles = this.ignoreStyles;
    
    cloned.mergeAdjacentStyles = this.mergeAdjacentStyles;
    cloned.optimizeWhitespace = this.optimizeWhitespace;
    cloned.enableStyleInheritance = this.enableStyleInheritance;
    
    cloned.allowedTags = [];
    for (let i = 0; i < this.allowedTags.length; i++) {
      cloned.allowedTags.push(this.allowedTags[i]);
    }
    
    cloned.disallowedTags = [];
    for (let i = 0; i < this.disallowedTags.length; i++) {
      cloned.disallowedTags.push(this.disallowedTags[i]);
    }
    
    return cloned;
  }
}