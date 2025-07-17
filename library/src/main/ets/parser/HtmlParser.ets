/**
 * HTML解析器
 * 
 * 负责将HTML字符串解析为结构化的元素树
 * 基于您提供的核心代码进行优化和扩展
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import { xml, util } from '@kit.ArkTS';
import { LogUtil } from '../utils/LogUtil';
import type { ParsedElement, ElementType, ParseOptions } from '../types/LiteRichTypes';
import { XMLWriter } from '@ohos/htmltoxml';
import { LiteRichConfig } from '../config/LiteRichConfig';

/**
 * XML属性接口
 */
interface XmlProperty {
  key: string;
  value: string;
}

export class HtmlParser {
  private readonly config: LiteRichConfig;
  private readonly parseOptions: ParseOptions;
  
  // ✅ 解析状态
  private elements: ParsedElement[] = [];
  private elementStack: ParsedElement[] = [];
  private loading: boolean = false;
  
  constructor(config?: LiteRichConfig) {
    this.config = config || new LiteRichConfig();
    this.parseOptions = {
      preserveWhitespace: this.config.preserveWhitespace,
      decodeEntities: this.config.decodeEntities,
      ignoreComments: this.config.ignoreComments,
      ignoreScripts: this.config.ignoreScripts,
      ignoreStyles: this.config.ignoreStyles
    };
  }
  
  /**
   * 解析HTML字符串
   * 
   * @param htmlContent - HTML内容
   * @returns 解析后的元素数组
   */
  public async parse(htmlContent: string): Promise<ParsedElement[]> {
    try {
      // 防止重复解析
      if (this.loading) {
        throw new Error('解析器正在运行中');
      }
      
      this.resetState();
      
      if (!htmlContent || htmlContent.length === 0) {
        return [];
      }
      
      // 检查是否为纯文本
      if (this.isPlainText(htmlContent)) {
        return [{
          type: 'text' as ElementType,
          textContent: htmlContent,
          startIndex: 0,
          endIndex: htmlContent.length
        }];
      }
      
      this.loading = true;

      // 内容长度限制
      if (htmlContent.length > this.config.maxContentLength) {
        throw new Error(`内容长度超过限制: ${htmlContent.length} > ${this.config.maxContentLength}`);
      }
      
      // 转换为XHTML
      const sanitizedXml: string = await this.toXhtml(`<root>${htmlContent}</root>`);
      LogUtil.debug('HtmlParser', 'sanitizedXml', sanitizedXml);
      
      // 编码为字节数组
      const arrBuffer: Uint8Array = this.encodeToBytes(sanitizedXml);
      
      // 创建XML解析器
      const xmlPullParser: xml.XmlPullParser = this.createXmlParser(arrBuffer);
      
      // 执行解析
      await this.executeXmlParsing(xmlPullParser);
      
      this.loading = false;
      
      LogUtil.debug('HtmlParser', `解析完成，元素数量: ${this.elements.length}`);
      
      return this.elements;
      
    } catch (error) {
      this.loading = false;
      LogUtil.error('HtmlParser', `解析失败: ${JSON.stringify(error)}`);
      
      // 降级到纯文本
      return [{
        type: 'text' as ElementType,
        textContent: htmlContent,
        startIndex: 0,
        endIndex: htmlContent.length
      }];
    }
  }
  
  /**
   * 重置解析状态
   */
  private resetState(): void {
    this.elements = [];
    this.elementStack = [];
  }
  
  /**
   * 检查是否为纯文本
   */
  private isPlainText(content: string): boolean {
    const htmlTagRegex: RegExp = /<[^>]+>/;
    return !htmlTagRegex.test(content);
  }
  
  /**
   * 转换HTML为XHTML - 基于您的核心代码
   */
  private async toXhtml(rawHtml: string): Promise<string> {
    return new Promise<string>((resolve, reject) => {
      const property: XmlProperty[] = [
        { key: XMLWriter.ENCODING, value: 'UTF-8' },
        { key: XMLWriter.OMIT_XML_DECLARATION, value: 'yes' }
      ];
      
      const writer = new XMLWriter(rawHtml, property);
      writer.convertToXML((content: string, error: Error | null) => {
        if (error) {
          reject(error);
        } else {
          // 去掉DOCTYPE声明，避免XmlPullParser拉取外网DTD导致阻塞
          const noDoctype: string = content.replace(/<!DOCTYPE[^>]*>/gi, '').trim();
          resolve(noDoctype);
        }
      });
    });
  }
  
  /**
   * 编码字符串为字节数组
   */
  private encodeToBytes(content: string): Uint8Array {
    try {
      const textEncoder: util.TextEncoder = new util.TextEncoder();
      const arrBuffer: Uint8Array = textEncoder.encodeInto(content);
      
      if (arrBuffer.length === 0) {
        throw new Error('文本编码失败');
      }
      
      return arrBuffer;
    } catch (error) {
      LogUtil.error('HtmlParser', `编码错误: ${JSON.stringify(error)}`);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(`编码失败: ${JSON.stringify(error)}`);
      }
    }
  }
  
  /**
   * 创建XML解析器
   */
  private createXmlParser(arrBuffer: Uint8Array): xml.XmlPullParser {
    try {
      // 将Uint8Array转换为ArrayBuffer，符合构造函数要求
      const arrayBuffer: ArrayBuffer = 
        arrBuffer.buffer.slice(arrBuffer.byteOffset, arrBuffer.byteOffset + arrBuffer.byteLength);
      
      return new xml.XmlPullParser(arrayBuffer, 'UTF-8');
    } catch (error) {
      LogUtil.error('HtmlParser', `创建解析器失败: ${JSON.stringify(error)}`);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(`创建解析器失败: ${JSON.stringify(error)}`);
      }
    }
  }
  
  /**
   * 执行XML解析
   */
  private async executeXmlParsing(xmlPullParser: xml.XmlPullParser): Promise<void> {
    const options: xml.ParseOptions = {
      supportDoctype: false, // 关闭DTD支持，避免BusinessError 401
      ignoreNameSpace: true,
      attributeValueCallbackFunction: (name: string, value: string): boolean => {
        return this.attributeValueCallback(name, value);
      },
      tokenValueCallbackFunction: (eventType: xml.EventType, value: xml.ParseInfo): boolean => {
        return this.tokenValueCallback(eventType, value);
      }
    };
    
    try {
      xmlPullParser.parseXml(options);
      LogUtil.debug('HtmlParser', `XML解析成功，结果是: ${JSON.stringify(this.elements)}`);
    } catch (error) {
      LogUtil.error('HtmlParser', `XML解析失败: ${JSON.stringify(error)}`);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(`XML解析失败: ${JSON.stringify(error)}`);
      }
    }
  }
  
  /**
   * 属性值回调函数
   */
  private attributeValueCallback(name: string, value: string): boolean {
    if (this.elementStack.length > 0) {
      const currentElement: ParsedElement = this.elementStack[this.elementStack.length - 1];
      if (!currentElement.attributes) {
        currentElement.attributes = {};
      }
      currentElement.attributes[name] = value;
    }
    return true;
  }
  
  /**
   * 标记值回调函数
   */
  private tokenValueCallback(eventType: xml.EventType, value: xml.ParseInfo): boolean {
    try {
      switch (eventType) {
        case xml.EventType.START_TAG:
          this.handleStartTag(value);
          break;
          
        case xml.EventType.END_TAG:
          this.handleEndTag(value);
          break;
          
        case xml.EventType.TEXT:
          this.handleText(value);
          break;
          
        case xml.EventType.CDSECT:
          this.handleCData(value);
          break;
          
        default:
          // 忽略其他事件类型
          break;
      }
      
      return true;
    } catch (error) {
      LogUtil.error('HtmlParser', `标记处理错误: ${JSON.stringify(error)}`);
      return false;
    }
  }
  
  /**
   * 处理开始标签
   */
  private handleStartTag(value: xml.ParseInfo): void {
    const tagName: string = value.getName();
    
    // 跳过root标签
    if (tagName === 'root') {
      return;
    }
    
    // 检查标签是否被允许
    if (!this.config.isTagAllowed(tagName)) {
      LogUtil.debug('HtmlParser', `跳过不允许的标签: ${tagName}`);
      return;
    }
    
    const element: ParsedElement = {
      type: 'tag' as ElementType,
      tagName: tagName.toLowerCase(),
      attributes: {},
      children: [],
      startIndex: 0, // 实际位置需要根据原始HTML计算
      endIndex: 0
    };
    
    // 处理自闭合标签
    if (this.isSelfClosingTag(tagName)) {
      element.type = 'self-closing' as ElementType;
      
      // 添加到当前父元素或根元素列表
      if (this.elementStack.length > 0) {
        const parent: ParsedElement = this.elementStack[this.elementStack.length - 1];
        if (!parent.children) {
          parent.children = [];
        }
        parent.children.push(element);
      } else {
        this.elements.push(element);
      }
    } else {
      // 普通标签，压入栈
      this.elementStack.push(element);
    }
  }
  
  /**
   * 处理结束标签
   */
  private handleEndTag(value: xml.ParseInfo): void {
    const tagName: string = value.getName();
    // 跳过root标签
    if (tagName === 'root') {
      return;
    }
    
    if (this.elementStack.length === 0) {
      return;
    }
    
    const element: ParsedElement = this.elementStack.pop()!;
    
    // 验证标签匹配
    if (element.tagName !== tagName.toLowerCase()) {
      LogUtil.warn('HtmlParser', `标签不匹配: 期望 ${element.tagName}, 实际 ${tagName}`);
    }
    
    // 添加到父元素或根元素列表
    if (this.elementStack.length > 0) {
      const parent: ParsedElement = this.elementStack[this.elementStack.length - 1];
      if (!parent.children) {
        parent.children = [];
      }
      parent.children.push(element);
    } else {
      this.elements.push(element);
    }
  }
  
  /**
   * 处理文本内容
   */
  private handleText(value: xml.ParseInfo): void {
    const text: string = value.getText();
    
    if (!text || text.trim().length === 0) {
      if (!this.parseOptions.preserveWhitespace) {
        return;
      }
    }
    
    const textElement: ParsedElement = {
      type: 'text' as ElementType,
      textContent: this.parseOptions.decodeEntities ? this.decodeHtmlEntities(text) : text,
      startIndex: 0,
      endIndex: text.length
    };
    
    // 添加到当前父元素或根元素列表
    if (this.elementStack.length > 0) {
      const parent: ParsedElement = this.elementStack[this.elementStack.length - 1];
      if (!parent.children) {
        parent.children = [];
      }
      parent.children.push(textElement);
    } else {
      this.elements.push(textElement);
    }
  }
  
  /**
   * 处理CDATA内容
   */
  private handleCData(value: xml.ParseInfo): void {
    const text: string = value.getText();
    
    const textElement: ParsedElement = {
      type: 'text' as ElementType,
      textContent: text,
      startIndex: 0,
      endIndex: text.length
    };
    
    // 添加到当前父元素或根元素列表
    if (this.elementStack.length > 0) {
      const parent: ParsedElement = this.elementStack[this.elementStack.length - 1];
      if (!parent.children) {
        parent.children = [];
      }
      parent.children.push(textElement);
    } else {
      this.elements.push(textElement);
    }
  }
  
  /**
   * 检查是否为自闭合标签
   */
  private isSelfClosingTag(tagName: string): boolean {
    const selfClosingTags: string[] = [
      'br', 'hr', 'img', 'input', 'area', 'base', 'col', 
      'embed', 'link', 'meta', 'param', 'source', 'track', 'wbr'
    ];
    
    return selfClosingTags.includes(tagName.toLowerCase());
  }
  
  /**
   * 解码HTML实体
   */
  private decodeHtmlEntities(text: string): string {
    const entityMap: Record<string, string> = {
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&#39;': "'",
      '&nbsp;': ' ',
      '&copy;': '©',
      '&reg;': '®',
      '&trade;': '™'
    };
    
    return text.replace(/&[a-zA-Z0-9#]+;/g, (entity: string): string => {
      return entityMap[entity] || entity;
    });
  }
  
  /**
   * 清理解析器
   */
  public clear(): void {
    this.resetState();
  }
}