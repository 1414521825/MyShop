import { cartViewModel, CartViewModel } from "../../viewmodels/CartViewModel";
import { CartListView } from "../Cart/CartListView";
import { CartTitleView } from "../Cart/CartTitleView";
import { StatisticsView } from "../Cart/StatisticsView";

@ComponentV2
export struct ShopCartTab {
  @Local
  cartViewModel: CartViewModel = cartViewModel;

  @Provider('updateChecked')
  updateChecked: (id: string, checked: boolean) => void = (id, checked) => {
    this.cartViewModel.updateItemChecked(id, checked);
  }

  @Provider('countChange')
  countChange: (id: string, op: string) => void = (id, op) => {
    if (op === 'add') {
      const item = this.cartViewModel.cartItemList.find(i => i.id === id);
      if (item) {
        this.cartViewModel.addCartItem(item.goods);
      }
    } else {
      this.cartViewModel.decreaseCartItem(id);
    }
  }

  build() {
    Column() {
      Stack() {
        CartListView({
          cartList: this.cartViewModel.cartItemList
        });

        Row() {
          CartTitleView({deleteCart: () => {
            this.cartViewModel.removeCheckedItems();
          }});
        }
        .layoutGravity(LocalizedAlignment.TOP)

        Row() {
          StatisticsView({
            buyCount: this.cartViewModel.buyCount,
            totalAmount: this.cartViewModel.totalPrice,
            isAllChecked: this.cartViewModel.isAllChecked,
            allCheckedChange: (isAllChecked) => {
              this.cartViewModel.allCheckedChange(isAllChecked);
            }
          })
        }
        .layoutGravity(LocalizedAlignment.BOTTOM)
      }
      .height(LayoutPolicy.matchParent)
      .backgroundColor($r('app.color.background_color'))
      .ignoreLayoutSafeArea()
    }
    .width('100%')
    .height('100%')
  }
}
