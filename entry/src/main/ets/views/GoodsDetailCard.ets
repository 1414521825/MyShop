import { GoodsItem } from '../models/Goods/GoodsItem'
import { cartViewModel, CartViewModel } from "../viewmodels/CartViewModel";

@ComponentV2
export struct GoodsDetailCard {
  @Require @Param
  goodsItem: GoodsItem;
  @Require @Param
  count: number;
  @Event
  onCountChange: (id: string, count: number) => void;
  @Event
  onClose: () => void;

  build() {
    Column() {
      // 关闭按钮
      Row() {
        Blank()
        Button('✕')
          .width(28).height(28)
          .fontSize(14)
          .fontColor(Color.Black)
          .backgroundColor('#F5F5F5')
          .padding(0)
          .onClick(() => this.onClose())
      }
      .width('100%')

      // 商品图片
      Image($r(this.goodsItem.goodsImage))
        .width('100%')
        .aspectRatio(1)
        .objectFit(ImageFit.Cover)
        .margin({ top: 8 })

      // 商品名称 + 价格
      Row() {
        Text(this.goodsItem.goodsName)
          .fontSize(15)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(`￥${this.goodsItem.goodsPrice}`)
          .fontColor('#FF4444')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ top: 8 })

      // 商品数量
      Row() {
        Text('数量')
          .fontSize(14)
        Button('加入购物车')
          .onClick(() => {
            cartViewModel.addCartItem(this.goodsItem);
            this.onClose();
          })

        Blank()
        Button('-')
          .width(28).height(28)
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(Color.Gray)
          .padding(0)
          .onClick(() => {
            if (this.count > 1) {
              this.onCountChange(this.goodsItem.id, this.count - 1);
            }
          })
        Text(`${this.count}`)
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .width(36)
        Button('+')
          .width(28).height(28)
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(Color.Gray)
          .padding(0)
          .onClick(() => {
            this.onCountChange(this.goodsItem.id, this.count + 1);
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 12, topRight: 12 })
    .width('100%')
  }
}