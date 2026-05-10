import { CartItemViewModel } from "../../viewmodels/Cart/CartItemViewModel"
import { CartListItemView } from "./CartListItemView";

@ComponentV2
export struct CartListView {
  @Require @Param
  cartList: CartItemViewModel[] = [];

  // @Builder装饰器用于封装可复用的UI结构
  @Builder
  itemHead() {
    Blank() // 空白填充组件
      .margin({ top: 106 })
  }

  // @Builder装饰器用于封装可复用的UI结构
  @Builder
  itemFooter() {
    Blank() // 空白填充组件
      .margin({ top: 84 })
  }

  build() {
    Column() {
      // space用于设置列表子项之间的距离
      List({space: 12}) {
        ListItemGroup({
          header: this.itemHead(),
          footer: this.itemFooter()
        }) {
          ForEach(this.cartList, (item: CartItemViewModel) => {
            ListItem() {
              CartListItemView({
                cartItem: item
              })
            }
          }, (item: CartItemViewModel) => item.id)
        }
        .divider({strokeWidth: 12, color: '#F1F3F5'})
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .sticky(StickyStyle.Header)
    }
    .margin({
      left: 16,
      right: 16
    })
  }
}