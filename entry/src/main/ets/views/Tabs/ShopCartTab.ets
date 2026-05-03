import { cartViewModel, CartViewModel } from "../../viewmodels/CartViewModel";
import { CartListView } from "../Cart/CartListView";
import { CartTitleView } from "../Cart/CartTitleView";
import { StatisticsView } from "../Cart/StatisticsView";

@ComponentV2
export struct ShopCartTab {
  @Local
  cartViewModel: CartViewModel = cartViewModel;
  @Local
  buyCount: number = 0;
  @Local
  totalPrice: number = 0;
  @Local
  isAllChecked: boolean = false;

  private refreshLocalState(): void {
    this.buyCount = this.cartViewModel.buyCount;
    this.totalPrice = this.cartViewModel.totalPrice;
    this.isAllChecked = this.cartViewModel.isAllChecked;
  }

  @Provider('updateChecked')
  updateChecked: (id: string, checked: boolean) => void = (id, checked) => {
    this.cartViewModel.updateItemChecked(id, checked);
    this.refreshLocalState();
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
    this.refreshLocalState();
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
            this.refreshLocalState();
          }});
        }
        .layoutGravity(LocalizedAlignment.TOP)

        Row() {
          StatisticsView({
            buyCount: this.buyCount,
            totalAmount: this.totalPrice,
            isAllChecked: this.isAllChecked,
            allCheckedChange: (isAllChecked) => {
              this.cartViewModel.allCheckedChange(isAllChecked);
              this.refreshLocalState();
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
