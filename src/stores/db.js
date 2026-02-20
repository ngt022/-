// IndexedDB 已废弃，数据全部走服务器
// 保留空导出避免其他文件报错
export class GameDB {
  static async getData() { return null }
  static async setData() {}
}
