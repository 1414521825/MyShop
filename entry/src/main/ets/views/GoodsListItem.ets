import { GoodsItemViewModel } from "../viewmodels/Goods/GoodsItemViewModel";

@ComponentV2
struct GoodsListItem {
  @Require @Param
  goodsItem: GoodsItemViewModel;
  @Event
  onItemClick: (item: GoodsItemViewModel) => void;

  build() {
    Column() {
      // 商品图片
      Image($r(this.goodsItem.goodsImage))
        .width('100%')
        .aspectRatio(1)
        .objectFit(ImageFit.Cover)
        // [CHG] 图片上两角匹配卡片的 borderRadius，不刺破圆角
        .borderRadius({ topLeft: 4, topRight: 4 })

      // [CHG] 内容区统一加左右 padding，不再靠边
      Column() {
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
            // .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(12)
            .margin({ left: 4 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ top: 6 })

        // 价格 + 销量 同行
        Row() {
          Text('券后')
            .fontColor(Color.Red)
            .fontSize(12)
            .margin({ right: 2 })
          Text(`¥${this.goodsItem.goodsPrice}`)
            .fontColor('#FF4444')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          Blank()
          Text('已拼200万+件')
            .fontColor(Color.Gray)
            .fontSize(10)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ top: 4, bottom: 6 })
      }
      .padding({ left: 8, right: 8 })
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    // [CHG] 卡片阴影 + 圆角 + 微边框，拼多多卡片质感三要素
    .shadow({ radius: 8, color: '#18000000', offsetY: 2 })
    .borderRadius(4)
    .border({ width: 0.5, color: '#F0F0F0' })
    .onClick(() => this.onItemClick(this.goodsItem))
  }
}

export default GoodsListItem;