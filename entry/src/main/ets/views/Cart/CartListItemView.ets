import { CartItem } from "../../models/Goods/CartItem"

@ComponentV2
export struct CartListItemView {
  @Require @Param
  cartItem: CartItem;

  @Consumer('countChange')
  countChange: (id: string, op: string) => void = () => {
  };
  @Consumer('updateChecked')
  updateChecked: (id: string, checked: boolean) => void = () => {
  };

  build() {
    Row() {
      Row() {
        Checkbox()
          .select(this.cartItem.checked)
          .width(20).height(20)
          .margin(2)
          .onChange((value: boolean) => {
            this.updateChecked(this.cartItem.id, value);
          })

        Image($r(this.cartItem.goods.goodsImage))
          .width(76)
          .height(76)
          .borderRadius(16)
          .margin({ left: 12 })
      }

      Column() {
        Row() {
          Column() {
            Text(this.cartItem.goods.goodsName)
              .height(21)
              .fontColor('rgba(0,0,0,0.9)')
              .fontSize(16)
              .fontWeight(500)

            Text('旅行')
              .height(16)
              .fontColor('rgba(0,0,0,0.4)')
              .fontSize(12)
              .fontWeight(400)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        Row() {
          Row() {
            Text('￥')
              .fontColor('rgba(0,0,0,0.9)')
              .fontWeight(700)
              .fontSize(12)
              .margin({ top: 4 })

            Text(this.cartItem.goods.goodsPrice.toString())
              .fontColor('rgba(0,0,0,0.9)')
              .fontWeight(700)
              .fontSize(16)
          }
          .layoutWeight(1)

          Row() {
            Button() {
              SymbolGlyph($r('sys.symbol.minus_circle'))
                .fontSize(26)
                .fontColor(['rgba(10,89,247,1)'])
            }
            .width(30).height(30)
            .borderRadius(15)
            .backgroundColor(Color.White)
            .enabled(this.cartItem.count > 0 ? true : false)
            .onClick(() => {
              this.countChange(this.cartItem.id, 'subtract');
            })

            Text(this.cartItem.count.toString())
              .width(30)
              .height(30)
              // textAlign设置文本段落在水平方向的对齐方式。
              // TextAlign.Center水平居中对齐。
              .textAlign(TextAlign.Center)

            Button() {
              SymbolGlyph($r('sys.symbol.plus_circle'))
                .fontSize(26)
                .fontColor(['rgba(10,89,247,1)'])
            }
            .width(30).height(30)
            .borderRadius(15)
            .backgroundColor(Color.White)
            .enabled(this.cartItem.count < this.cartItem.stock ? true : false)
            .onClick(() => {
              this.countChange(this.cartItem.id, 'add');
            })
          }
        }
        .height(24)
        .margin({ top: 19, right: 0 })
        // justifyContent用于设置子组件在垂直方向上的对齐格式
        // FlexAlign.SpaceBetween相邻元素之间距离相同。第一个元素与行首对齐，最后一个元素与行尾对齐
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      // alignItems设置子组件在水平方向上的对齐格式
      // HorizontalAlign.Start 左对齐
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(104)
    .borderRadius(16)
    .padding(12)
    .backgroundColor(Color.White)
  }
}