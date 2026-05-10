import { util } from "@kit.ArkTS";
import { GoodsItemModel } from "../Goods/GoodsItemModel";

export class CartItemModel {
  id: string;
  goods: GoodsItemModel;
  checked: boolean = false; // 选中状态
  count: number = 0; // 商品数量
  stock: number; // 库存数量

  constructor(goods: GoodsItemModel, count: number = 1, stock: number = 10) {
    this.id = goods.id;
    this.goods = goods;
    this.count = count;
    this.stock = stock;
  }
}