@ObservedV2
export class GoodsItem {
  // 商品唯一ID
  @Trace
  id: string;
  // 商品名称
  @Trace
  goodsName: string;
  // 商品价格
  @Trace
  goodsPrice: number;
  // 商品描述
  @Trace
  goodsDesc: string;
  // 商品图片
  @Trace
  goodsImage: string;

  constructor(id: string, goodsName: string, goodsPrice: number, goodsDesc: string, goodsImage: string = "app.media.a") {
    this.id = id;
    this.goodsName = goodsName;
    this.goodsPrice = goodsPrice;
    this.goodsDesc = goodsDesc;
    this.goodsImage = goodsImage;
  }
}