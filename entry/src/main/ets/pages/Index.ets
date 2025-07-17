/**
 * LiteRich使用示例 - 符合ArkTS规范
 * 
 * 展示如何使用LiteRich组件进行富文本渲染
 * 
 * @since 1.0.0
 */

import { LiteRich, LiteRichOptions } from 'library';

@Entry
@Component
struct LiteRichDemo {
  @State private htmlContent: string = `
    <h1>LiteRich富文本组件演示</h1>
    <p>这是一个<strong>功能强大</strong>的富文本组件，支持多种HTML标签。</p>
    
    <h2>文本样式</h2>
    <p>支持<b>粗体</b>、<i>斜体</i>、<u>下划线</u>、<s>删除线</s>等样式。</p>
    
    <h3>链接和交互</h3>
    <p>点击这个<a href="https://developer.huawei.com">华为开发者官网</a>链接。</p>
    
    <h3>代码展示</h3>
    <p>内联代码：<code>console.log('Hello World')</code></p>
    
    <h3>其他元素</h3>
    <p>分割线：</p>
    <hr>
    <p>换行测试：<br>这是新的一行。</p>
    
    <p><small>这是小字体文本</small></p>
    <p><mark>这是高亮文本</mark></p>
  `;
  
  @State private currentTime: string = '';
  @State private randomNumber: number = 0;
  
  // LiteRich配置选项
  private readonly liteRichOptions: LiteRichOptions = {
    maxContentLength: 10000,
    textAlign: TextAlign.Start,
    maxLines: -1,
    fontSize: 16,
    fontColor: '#333333',
    debug: true,
    eventHandlers: {
      onLinkClick: (url: string) => {
        console.info(`链接点击: ${url}`);
        // 这里可以处理链接点击事件
      }
    }
  };

  build(): void {
    Scroll() {
      Column({ space: 20 }) {
        // 标题
        Text('LiteRich富文本组件演示')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a1a1a')
          .margin({ top: 20, bottom: 20 })
          .textAlign(TextAlign.Center)
        
        // 富文本内容展示区域
        Column() {
          Text('富文本内容预览')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 10 })
          
          // 使用我们的LiteRich组件
          LiteRich({
            text: this.htmlContent,
            options: this.liteRichOptions
          })
            .width('100%')
            .backgroundColor('#ffffff')
            .padding(16)
            .borderRadius(8)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#f8f9fa')
        .borderRadius(12)
        
        Divider()
          .color('#e0e0e0')
        
        // 功能测试区域
        Text('功能测试')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a1a1a')
        
        // 测试按钮
        Row({ space: 10 }) {
          Button('更新内容')
            .type(ButtonType.Capsule)
            .backgroundColor('#007AFF')
            .onClick(() => {
              this.updateContent();
            })
            .layoutWeight(1)
          
          Button('清空内容')
            .type(ButtonType.Capsule)
            .backgroundColor('#FF3B30')
            .onClick(() => {
              this.htmlContent = '';
            })
            .layoutWeight(1)
          
          Button('重置内容')
            .type(ButtonType.Capsule)
            .backgroundColor('#34C759')
            .onClick(() => {
              this.resetContent();
            })
            .layoutWeight(1)
        }
        .width('100%')
        
        Row({ space: 10 }) {
          Button('测试长文本')
            .type(ButtonType.Capsule)
            .backgroundColor('#FF9500')
            .onClick(() => {
              this.loadLongContent();
            })
            .layoutWeight(1)
          
          Button('样式测试')
            .type(ButtonType.Capsule)
            .backgroundColor('#5856D6')
            .onClick(() => {
              this.loadStyleTest();
            })
            .layoutWeight(1)
        }
        .width('100%')
        
        // 状态信息
        Column({ space: 8 }) {
          Text(`当前内容长度: ${this.htmlContent.length} 字符`)
            .fontSize(14)
            .fontColor('#666666')
          
          if (this.currentTime) {
            Text(`最后更新时间: ${this.currentTime}`)
              .fontSize(12)
              .fontColor('#999999')
          }
          
          if (this.randomNumber > 0) {
            Text(`随机数: ${this.randomNumber}`)
              .fontSize(12)
              .fontColor('#999999')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ top: 10 })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
  
  /**
   * 更新内容
   */
  private updateContent(): void {
    this.currentTime = new Date().toLocaleString();
    this.randomNumber = Math.floor(Math.random() * 1000);
    
    const newContent = `
      <h2>🔄 动态更新的内容</h2>
      <p>这是通过按钮动态更新的内容。</p>
      <p>当前时间：<strong>${this.currentTime}</strong></p>
      <p>随机数：<code>${this.randomNumber}</code></p>
      <a href="https://example.com">动态链接</a>
      <hr>
      <p><mark>内容已更新！</mark></p>
    `;
    
    this.htmlContent = newContent;
  }
  
  /**
   * 重置内容
   */
  private resetContent(): void {
    this.currentTime = '';
    this.randomNumber = 0;
    
    this.htmlContent = `
      <h1>LiteRich富文本组件演示</h1>
      <p>这是一个<strong>功能强大</strong>的富文本组件，支持多种HTML标签。</p>
      
      <h2>文本样式</h2>
      <p>支持<b>粗体</b>、<i>斜体</i>、<u>下划线</u>、<s>删除线</s>等样式。</p>
      
      <h3>链接和交互</h3>
      <p>点击这个<a href="https://developer.huawei.com">华为开发者官网</a>链接。</p>
      
      <h3>代码展示</h3>
      <p>内联代码：<code>console.log('Hello World')</code></p>
      
      <h3>其他元素</h3>
      <p>分割线：</p>
      <hr>
      <p>换行测试：<br>这是新的一行。</p>
      
      <p><small>这是小字体文本</small></p>
      <p><mark>这是高亮文本</mark></p>
    `;
  }
  
  /**
   * 加载长文本内容
   */
  private loadLongContent(): void {
    this.currentTime = new Date().toLocaleString();
    
    this.htmlContent = `
      <h1>📚 长文本测试</h1>
      <p>这是一个用于测试组件性能的长文本内容。</p>
      
      <h2>第一章：介绍</h2>
      <p>LiteRich是一个专为鸿蒙应用开发的<strong>高性能富文本组件</strong>。它采用了先进的渲染技术和优化策略，能够处理复杂的HTML内容。</p>
      
      <h3>主要特性</h3>
      <p>• <b>高性能渲染</b>：采用虚拟化技术，支持大量文本内容</p>
      <p>• <i>丰富的样式支持</i>：支持多种HTML标签和CSS样式</p>
      <p>• <u>交互功能</u>：支持链接点击、自定义事件等</p>
      <p>• <s>安全可靠</s> <mark>安全可靠</mark>：内置XSS防护和内容过滤</p>
      
      <h2>第二章：使用方法</h2>
      <p>使用LiteRich非常简单，只需要几行代码：</p>
      <code>LiteRich({ text: htmlContent })</code>
      
      <h3>配置选项</h3>
      <p>组件提供了丰富的配置选项，可以根据需要进行定制。</p>
      
      <hr>
      
      <h2>第三章：性能优化</h2>
      <p>为了确保最佳性能，组件采用了以下优化策略：</p>
      <p>1. <strong>缓存机制</strong>：解析结果会被缓存，避免重复计算</p>
      <p>2. <strong>懒加载</strong>：只渲染可见区域的内容</p>
      <p>3. <strong>内存管理</strong>：自动清理不再使用的资源</p>
      
      <p><small>更多信息请参考官方文档。</small></p>
      
      <a href="https://developer.huawei.com">查看更多</a>
    `;
  }
  
  /**
   * 样式测试
   */
  private loadStyleTest(): void {
    this.currentTime = new Date().toLocaleString();
    
    this.htmlContent = `
      <h1>🎨 样式测试</h1>
      <p>测试各种文本样式和格式。</p>
      
      <h2>基础样式</h2>
      <p>这是<b>粗体文本</b>，这是<i>斜体文本</i>。</p>
      <p>这是<u>下划线文本</u>，这是<s>删除线文本</s>。</p>
      <p>这是<strong>重要文本</strong>，这是<em>强调文本</em>。</p>
      
      <h3>代码样式</h3>
      <p>内联代码：<code>const message = 'Hello World';</code></p>
      <p>另一个代码示例：<code>function test() { return true; }</code></p>
      
      <h3>特殊元素</h3>
      <p>这是<small>小字体文本</small>，正常大小文本。</p>
      <p>这是<mark>高亮标记文本</mark>，正常文本。</p>
      
      <h3>链接测试</h3>
      <p>访问<a href="https://developer.huawei.com">华为开发者中心</a>获取更多信息。</p>
      <p>或者查看<a href="https://gitee.com/openharmony">OpenHarmony代码仓库</a>。</p>
      
      <hr>
      
      <h4>混合样式</h4>
      <p>这段文本包含<b>粗体</b>、<i>斜体</i>、<u>下划线</u>和<mark>高亮</mark>等多种样式。</p>
      <p>代码示例：<code><b>const</b> result = <i>calculate</i>();</code></p>
    `;
  }
}