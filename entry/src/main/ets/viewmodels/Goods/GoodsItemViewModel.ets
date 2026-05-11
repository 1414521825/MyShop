import { GoodsItemModel } from "../../models/Goods/GoodsItemModel";

@ObservedV2
export class GoodsItemViewModel {
  // 商品唯一ID
  @Trace id: string;
  // 商品名称
  @Trace goodsName: string;
  // 商品价格
  @Trace goodsPrice: number;
  // 商品描述
  @Trace goodsDesc: string;
  // 商品图片
  @Trace goodsImage: string;

  constructor(id: string, goodsName: string, goodsPrice: number, goodsDesc: string, goodsImage: string = "app.media.p1") {
    this.id = id;
    this.goodsName = goodsName;
    this.goodsPrice = goodsPrice;
    this.goodsDesc = goodsDesc;
    this.goodsImage = goodsImage;
  }

  static fromModel(model: GoodsItemModel): GoodsItemViewModel {
    return new GoodsItemViewModel(
      model.id,
      model.goodsName,
      model.goodsPrice,
      model.goodsDesc,
      model.goodsImage
    );
  }
}