import { CartItemViewModel } from "./CartItemViewModel";
import { GoodsItemViewModel } from "../Goods/GoodsItemViewModel";


@ObservedV2
export class CartViewModel {
  @Trace
  cartItemList: CartItemViewModel[] = [];

  loadCartItemList(): void {

  }

  @Computed
  get totalPrice(): number {
    // return this.cartItemList
    //   .reduce((sum, item) => item.checked ? (sum + item.goods.goodsPrice) : sum, 0);
    return this.cartItemList
      .filter(item => item.checked)
      .reduce((sum, item) => sum + item.goods.goodsPrice * item.count, 0);
  }

  @Computed
  get isAllChecked(): boolean {
    if (this.cartItemList.length == 0) {
      return false;
    }
    return this.cartItemList
      .every(item => item.checked);
  }

  @Computed
  get buyCount(): number {
    return this.cartItemList
      .filter(item => item.checked)
      .reduce((sum, item) => sum + item.count, 0);
  }

  addCartItem(goods: GoodsItemViewModel, count: number): void {
    const exist = this.cartItemList.find(item => item.id === goods.id);
    if (exist) {
      exist.count = Math.min(exist.count + count, exist.stock);
      this.cartItemList = [...this.cartItemList];
    } else {
      this.cartItemList = [...this.cartItemList, new CartItemViewModel(goods, count)];
    }
  }

  decreaseCartItem(id: string): void {
    const index = this.cartItemList.findIndex(item => item.id === id);
    if (index === -1) {
      return;
    }
    const item = this.cartItemList[index];
    if (item.count > 1) {
      item.count--;
      this.cartItemList = [...this.cartItemList];
    } else {
      this.cartItemList = this.cartItemList.filter(i => i.id !== id);
    }
  }

  removeCheckedItems(): void {
    this.cartItemList = this.cartItemList.filter(item => !item.checked);
  }

  updateItemChecked(id: string, checked: boolean): void {
    const item = this.cartItemList.find(i => i.id === id);
    if (item) {
      item.checked = checked;
      this.cartItemList = [...this.cartItemList];
    }
  }

  allCheckedChange(isAllChecked: boolean): void {
    this.cartItemList.forEach(item => item.checked = isAllChecked);
    this.cartItemList = [...this.cartItemList];
  }
}

export const cartViewModel = new CartViewModel();
