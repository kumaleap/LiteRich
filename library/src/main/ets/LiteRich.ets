/**
 * LiteRich - 高性能富文本组件
 * 
 * 基于属性字符串(StyledString)实现的富文本渲染组件
 * 支持HTML标签解析、自定义样式、事件处理等功能
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import { LiteRichConfig } from './config/LiteRichConfig';
import { TagStyleManager } from './style/TagStyleManager';
import { HtmlParser } from './parser/HtmlParser';
import { StyledStringBuilder } from './builder/StyledStringBuilder';
import { LogUtil } from './utils/LogUtil';
import type { 
  LiteRichOptions, 
  ParsedElement,
  RenderContext 
} from './types/LiteRichTypes';

@Component
export struct LiteRich {
  // ✅ 最小化状态变量数量
  @State private loading: boolean = false;
  @State private styledString: StyledString = new StyledString('');
  
  // ✅ 配置和管理器实例
  private readonly config: LiteRichConfig = new LiteRichConfig();
  private readonly styleManager: TagStyleManager = new TagStyleManager();
  private readonly htmlParser: HtmlParser = new HtmlParser();
  private readonly stringBuilder: StyledStringBuilder = new StyledStringBuilder();
  
  // ✅ 缓存机制
  private parsedContent: string = '';
  private textController: TextController = new TextController();
  
  // ✅ 组件参数
  @Prop @Watch('onTextChange') text: string = '';
  @Prop options?: LiteRichOptions;
  
  aboutToAppear(): void {
    this.initializeComponent();
  }
  
  aboutToDisappear(): void {
    this.cleanup();
  }
  
  /**
   * 初始化组件
   */
  private initializeComponent(): void {
    // 应用用户配置
    if (this.options) {
      this.config.updateConfig(this.options);
    }
    
    // 注册默认样式
    this.styleManager.registerDefaultStyles();
    
    // 注册用户自定义样式
    if (this.options?.customStyles) {
      const tagNames: string[] = Object.keys(this.options.customStyles);
      for (let i = 0; i < tagNames.length; i++) {
        const tagName: string = tagNames[i];
        this.styleManager.registerTagStyle(tagName, this.options.customStyles[tagName]);
      }
    }
    
    // 初始解析
    this.parseAndRender();
  }
  
  /**
   * 清理资源
   */
  private cleanup(): void {
    this.styleManager.clear();
    this.htmlParser.clear();
    // this.stringBuilder.clear();
  }
  
  /**
   * 监听text属性变化
   */
  private onTextChange(): void {
    if (this.text !== this.parsedContent) {
      this.parseAndRender();
    }
  }
  
  /**
   * 解析并渲染HTML内容
   */
  private async parseAndRender(): Promise<void> {
    try {
      const currentText: string = this.text || '';
      
      // 防止重复解析
      if (this.loading || currentText === this.parsedContent) {
        return;
      }
      
      // 处理空文本
      if (currentText.length === 0) {
        this.styledString = new StyledString('');
        this.parsedContent = '';
        return;
      }
      
      // 检查是否为纯文本
      if (this.isPlainText(currentText)) {
        this.styledString = new StyledString(currentText);
        this.parsedContent = currentText;
        return;
      }
      
      this.loading = true;
      this.parsedContent = currentText;
      
      // 内容长度限制
      if (currentText.length > this.config.maxContentLength) {
        LogUtil.warn('LiteRich', '内容过大，使用纯文本显示');
        this.fallbackToPlainText(currentText);
        return;
      }
      
      // 解析HTML
      const parsedElements: ParsedElement[] = await this.htmlParser.parse(currentText);
      
      // 构建StyledString
      const renderContext: RenderContext = {
        config: this.config,
        styleManager: this.styleManager,
        eventHandlers: this.options?.eventHandlers || {}
      };
      
      this.styledString = this.stringBuilder.build(parsedElements, renderContext);
      
      // 绑定到Text组件
      this.textController.setStyledString(this.styledString);
      
      this.loading = false;
      
      LogUtil.debug('LiteRich', `解析完成，内容长度: ${this.styledString.length}`);
      
    } catch (error) {
      LogUtil.error('LiteRich', `解析异常: ${JSON.stringify(error)}`);
      this.fallbackToPlainText(this.text || '');
    }
  }
  
  /**
   * 检查是否为纯文本
   */
  private isPlainText(content: string): boolean {
    // 简单的HTML标签检测
    const htmlTagRegex: RegExp = /<[^>]+>/;
    return !htmlTagRegex.test(content);
  }
  
  /**
   * 降级到纯文本显示
   */
  private fallbackToPlainText(content: string): void {
    this.styledString = new StyledString(content);
    this.textController.setStyledString(this.styledString);
    this.loading = false;
  }
  
  build(): void {
    Column() {
      if (this.loading) {
        // ✅ 加载状态指示器
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
          Text('解析中...')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ left: 8 })
        }
        .justifyContent(FlexAlign.Center)
        .padding(16)
      } else {
        // ✅ 主要内容区域 - 正确的Text组件controller使用方式
        Text(undefined, { controller: this.textController })
          .width('100%')
          .textAlign(this.config.textAlign)
          .maxLines(this.config.maxLines)
          .textOverflow(this.config.textOverflow)
          .lineHeight(this.config.lineHeight)
          .fontSize(this.config.fontSize)
          .fontColor(this.config.fontColor)
          .fontFamily(this.config.fontFamily)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}