/**
 * 日志工具类
 * 
 * 提供统一的日志记录功能
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

export class LogUtil {
  private static debugEnabled: boolean = true;
  private static readonly LOG_TAG: string = 'LiteRichTag';
  
  /**
   * 设置调试模式
   * 
   * @param enabled - 是否启用调试
   */
  public static setDebugEnabled(enabled: boolean): void {
    LogUtil.debugEnabled = enabled;
  }
  
  /**
   * 检查是否启用调试模式
   * 
   * @returns 是否启用调试
   */
  public static isDebugEnabled(): boolean {
    return LogUtil.debugEnabled;
  }
  
  /**
   * 调试日志
   * 
   * @param tag - 标签
   * @param message - 消息
   * @param data - 附加数据
   */
  public static debug(tag: string, message: string, data?: string): void {
    if (LogUtil.debugEnabled) {
      const fullMessage: string = data ? `${message} ${data}` : message;
      console.debug(`[${LogUtil.LOG_TAG}][${tag}] ${fullMessage}`);
    }
  }
  
  /**
   * 信息日志
   * 
   * @param tag - 标签
   * @param message - 消息
   * @param data - 附加数据
   */
  public static info(tag: string, message: string, data?: string): void {
    const fullMessage: string = data ? `${message} ${data}` : message;
    console.info(`[${LogUtil.LOG_TAG}][${tag}] ${fullMessage}`);
  }
  
  /**
   * 警告日志
   * 
   * @param tag - 标签
   * @param message - 消息
   * @param data - 附加数据
   */
  public static warn(tag: string, message: string, data?: string): void {
    const fullMessage: string = data ? `${message} ${data}` : message;
    console.warn(`[${LogUtil.LOG_TAG}][${tag}] ${fullMessage}`);
  }
  
  /**
   * 错误日志
   * 
   * @param tag - 标签
   * @param message - 消息
   * @param data - 附加数据
   */
  public static error(tag: string, message: string, data?: string): void {
    const fullMessage: string = data ? `${message} ${data}` : message;
    console.error(`[${LogUtil.LOG_TAG}][${tag}] ${fullMessage}`);
  }
  
  /**
   * 性能日志
   * 
   * @param tag - 标签
   * @param operation - 操作名称
   * @param startTime - 开始时间
   */
  public static performance(tag: string, operation: string, startTime: number): void {
    if (LogUtil.debugEnabled) {
      const duration: number = Date.now() - startTime;
      console.info(`[${LogUtil.LOG_TAG}][Performance][${tag}] ${operation} 耗时: ${duration}ms`);
    }
  }
  
  /**
   * 开始性能计时
   * 
   * @returns 开始时间戳
   */
  public static startTiming(): number {
    return Date.now();
  }
}