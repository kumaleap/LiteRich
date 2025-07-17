/**
 * LiteRich组件简化测试版本
 * 
 * 用于验证基本功能和语法正确性
 */

@Component
export struct LiteRichSimple {
  @Prop text: string = '';
  @State private displayText: string = '';
  
  aboutToAppear(): void {
    this.displayText = this.text || '默认文本内容';
  }
  
  build(): void {
    Column() {
      Text(this.displayText)
        .fontSize(16)
        .fontColor('#333333')
        .width('100%')
        .padding(16)
    }
    .width('100%')
  }
}