import { GoodsItem } from "../models/Goods/GoodsItem";

@ObservedV2
export class GoodsListViewModel {
  @Trace goodsList: GoodsItem[] = [];
  @Trace isLoading: boolean = false;
  @Trace isRefreshing : boolean = false;

  // 加载商品列表 Todo mock换成网络数据
  loadGoodsList(): void {
    this.isLoading = true;
    this.goodsList = [
      new GoodsItem('1', '苹果 iPhone 15 Pro Max', 7999, 'A17 Pro 芯片'),
      new GoodsItem('2', '华为 Mate 60 Pro', 6999, '麒麟 9000S'),
      new GoodsItem('3', '小米 14 Ultra', 5999, '骁龙 8 Gen 3'),
    ];
    this.isLoading = false;
  }
}