import { GoodsItemModel } from '../models/Goods/GoodsItemModel';
import { httpClient } from './HttpClient';

export  class GoodsService {
  httpClient = httpClient;

  async getGoodsList(): Promise<GoodsItemModel[]> {
    // TODO: 切真实接口 → return httpClient.get('/api/goods')
    return [
      new GoodsItemModel('1', '苹果 iPhone 15 Pro Max 256GB', 7999, 'A17 Pro 芯片 | 钛金属', 'app.media.p1'),
      new GoodsItemModel('2', '华为 Mate 60 Pro', 6999, '麒麟 9000S | 卫星通话', 'app.media.p2'),
      new GoodsItemModel('3', '小米 14 Ultra', 5999, '骁龙 8 Gen 3 | 徕卡光学', 'app.media.p3'),
      new GoodsItemModel('4', '戴森 V15 无线吸尘器', 4990, '激光探测 | 60分钟续航', 'app.media.p4'),
      new GoodsItemModel('5', '良品铺子坚果大礼包 2kg', 99, '6种坚果 | 年货送礼', 'app.media.p5'),
      new GoodsItemModel('6', '优衣库轻薄羽绒服', 499, '90%白鸭绒 | 可收纳', 'app.media.p2'),
      new GoodsItemModel('7', '飞天茅台 53度 500ml', 2699, '酱香型 | 正品保证', 'app.media.p1'),
      new GoodsItemModel('8', '戴尔 27寸 4K显示器 U2723QE', 3299, 'IPS Black | Type-C 90W', 'app.media.p3'),
      new GoodsItemModel('9', '三只松鼠巨型零食大礼包', 139, '30袋装 | 追剧必备', 'app.media.p5'),
      new GoodsItemModel('10', '科沃斯 T30 扫地机器人', 3499, '自动集尘 | 热水洗拖布', 'app.media.p4'),
    ];
  }
}

export const goodsService = new GoodsService();