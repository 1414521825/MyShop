import { GoodsItemViewModel } from "../Goods/GoodsItemViewModel";

@ObservedV2
export class CartItemViewModel {
  @Trace id: string;
  @Trace goods: GoodsItemViewModel;
  @Trace checked: boolean = false; // 选中状态
  @Trace count: number; // 商品数量
  @Trace stock: number; // 库存数量

  constructor(goods: GoodsItemViewModel, count: number = 1, stock: number = 10) {
    this.id = goods.id;
    this.goods = goods;
    this.count = count;
    this.stock = stock;
  }
}