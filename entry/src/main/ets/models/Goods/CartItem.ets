import { util } from "@kit.ArkTS";
import { GoodsItem } from "./GoodsItem";

@ObservedV2
export class CartItem {
  id: string;
  goods: GoodsItem;
  @Trace checked: boolean = false; // 选中状态
  @Trace count: number = 0; // 商品数量
  stock: number; // 库存数量

  constructor(goods: GoodsItem, count: number = 1, stock: number = 10) {
    this.id = goods.id;
    this.goods = goods;
    this.count = count;
    this.stock = stock;
  }
}