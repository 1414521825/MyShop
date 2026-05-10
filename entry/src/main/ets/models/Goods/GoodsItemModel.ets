export class GoodsItemModel {
  // 商品唯一ID
  id: string;
  // 商品名称
  goodsName: string;
  // 商品价格
  goodsPrice: number;
  // 商品描述
  goodsDesc: string;
  // 商品图片
  goodsImage: string;

  constructor(id: string, goodsName: string, goodsPrice: number, goodsDesc: string, goodsImage: string = "app.media.p1") {
    this.id = id;
    this.goodsName = goodsName;
    this.goodsPrice = goodsPrice;
    this.goodsDesc = goodsDesc;
    this.goodsImage = goodsImage;
  }
}