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
import type { LiteRichOptions, ParsedElement, RenderContext } from './types/LiteRichTypes';

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
  
  // ✅ 新增：标记Text组件是否已准备好
  @State private textReady: boolean = false;
  
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

    // ✅ 延迟解析，等待Text组件准备好
    // this.parseAndRender();
  }

  /**
   * 清理资源
   */
  private cleanup(): void {
    this.styleManager.clear();
    this.htmlParser.clear();
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
   * ✅ 新增：Text组件准备完成回调
   */
  private onTextReady(): void {
    this.textReady = true;
    // Text组件准备好后，开始解析
    this.parseAndRender();
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
        // ✅ 安全调用setStyledString
        this.safeSetStyledString(this.styledString);
        return;
      }

      // 检查是否为纯文本
      if (this.isPlainText(currentText)) {
        this.styledString = new StyledString(currentText);
        this.parsedContent = currentText;
        // ✅ 安全调用setStyledString
        this.safeSetStyledString(this.styledString);
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

      LogUtil.debug("HtmlParser", "解析结果：" + JSON.stringify(parsedElements))

      // 构建StyledString
      const renderContext: RenderContext = {
        config: this.config,
        styleManager: this.styleManager,
        eventHandlers: this.options?.eventHandlers || {}
      };

      this.styledString = this.stringBuilder.build(parsedElements, renderContext);
      LogUtil.debug("HtmlParser", "StyledString：" + JSON.stringify(this.styledString))
      
      // ✅ 安全调用setStyledString
      this.safeSetStyledString(this.styledString);

      this.loading = false;

      LogUtil.debug('HtmlParser', `解析完成，内容长度: ${this.styledString.length}`);

    } catch (error) {
      LogUtil.error('HtmlParser', `解析异常: ${JSON.stringify(error)}`);
      this.fallbackToPlainText(this.text || '');
    }
  }

  /**
   * ✅ 新增：安全调用setStyledString方法
   */
  private safeSetStyledString(styledString: StyledString): void {
    if (this.textReady) {
      try {
        this.textController.setStyledString(styledString);
        LogUtil.debug('LiteRich', 'setStyledString调用成功');
      } catch (error) {
        LogUtil.error('LiteRich', `setStyledString调用失败: ${JSON.stringify(error)}`);
        // 降级处理：直接更新状态变量
        this.styledString = styledString;
      }
    } else {
      LogUtil.debug('LiteRich', 'Text组件未准备好，延迟设置StyledString');
      // Text组件未准备好，直接更新状态变量
      this.styledString = styledString;
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
    // ✅ 安全调用setStyledString
    this.safeSetStyledString(this.styledString);
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
        // ✅ 修复文字重叠问题
        Text(undefined, { controller: this.textController })
          .width('100%')
          .textAlign(this.config.textAlign)
          .maxLines(this.config.maxLines)
          .textOverflow(this.config.textOverflow)
          .lineHeight(this.getAdjustedLineHeight()) // ✅ 使用调整后的行高
          .fontSize(this.config.fontSize)
          .fontColor(this.config.fontColor)
          .fontFamily(this.config.fontFamily)
          .padding({ top: 2, bottom: 2 }) // ✅ 添加垂直内边距
          .onAppear(() => {
            // ✅ Text组件渲染完成后的回调
            this.onTextReady();
          })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * ✅ 新增：获取调整后的行高
   */
  private getAdjustedLineHeight(): number | string | Resource {
    // 确保行高足够，避免文字重叠
    if (typeof this.config.lineHeight === 'number') {
      return Math.max(1.6, this.config.lineHeight); // 最小行高1.6
    }
    return this.config.lineHeight;
  }
}