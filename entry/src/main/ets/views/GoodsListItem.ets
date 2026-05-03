import { GoodsItem } from '../models/Goods/GoodsItem';

@ComponentV2
struct GoodsListItem {
  @Require @Param
  goodsItem: GoodsItem;
  @Event
  onItemClick: (item: GoodsItem) => void;

  build() {
    Column() {
      // 商品图片：宽度撑满卡片，正方形
      Image($r(this.goodsItem.goodsImage))
        .width('100%')
        .aspectRatio(1)
        .objectFit(ImageFit.Cover)
        .borderRadius(4)

      // 标签 + 名称 同行
      Row() {
        Text('五一大促')
          .fontColor(Color.White)
          .backgroundColor(Color.Red)
          .fontSize(10)
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .borderRadius(2)
        Text(this.goodsItem.goodsName)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(13)
          .margin({ left: 4 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: 6 })

      // 价格 + 销量 同行
      Row() {
        Text('券后')
          .fontColor(Color.Red)
          .fontSize(14)
          .margin({right: 2})
        Text(`¥${this.goodsItem.goodsPrice}`)
          .fontColor('#FF4444')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('本店已拼200万+件')
          .fontColor(Color.Gray)
          .fontSize(10)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: 4 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .onClick(() => this.onItemClick(this.goodsItem))
  }
}

export default GoodsListItem;