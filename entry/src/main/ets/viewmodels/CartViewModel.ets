import { CartItem } from "../models/Goods/CartItem";
import { GoodsItem } from "../models/Goods/GoodsItem";

@ObservedV2
export class CartViewModel {
  @Trace
  cartItemList: CartItem[] = [];
  @Trace
  isAllChecked: boolean = false;
  @Trace
  buyCount: number = 0;
  @Trace
  totalPrice: number = 0;

  loadCartItemList(): void {

  }

  addCartItem(goods: GoodsItem): void {
    const exist = this.cartItemList.find(item => item.id === goods.id);
    if (exist) {
      exist.count++;
      this.cartItemList = [...this.cartItemList];
    } else {
      this.cartItemList = [...this.cartItemList, new CartItem(goods)];
    }
    this.refreshDerived();
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
    this.refreshDerived();
  }

  removeCheckedItems(): void {
    this.cartItemList = this.cartItemList.filter(item => !item.checked);
    this.refreshDerived();
  }

  updateItemChecked(id: string, checked: boolean): void {
    const item = this.cartItemList.find(i => i.id === id);
    if (item) {
      item.checked = checked;
      this.cartItemList = [...this.cartItemList];
      this.refreshDerived();
    }
  }

  allCheckedChange(isAllChecked: boolean): void {
    this.cartItemList.forEach(item => item.checked = isAllChecked);
    this.cartItemList = [...this.cartItemList];
    this.refreshDerived();
  }

  private refreshDerived(): void {
    this.buyCount = this.cartItemList
      .reduce((sum, item) => item.checked ? sum + item.count : sum, 0);
    this.isAllChecked = this.cartItemList.length > 0
      && this.cartItemList.every(item => item.checked);
    this.cartItemList.forEach(item => {
      console.log(`商品名称：${item.goods.goodsName};商品数量：${item.goods.goodsPrice};商品数量：${item.count};商品状态:${item.checked}`)
    })
    this.totalPrice = this.cartItemList
      .reduce((sum, item) => item.checked ? sum + item.count * item.goods.goodsPrice : sum, 0);
    console.log('>>> CartViewModel.refreshDerived: buyCount=' + this.buyCount
      + ', totalPrice=' + this.totalPrice
      + ', isAllChecked=' + this.isAllChecked);
  }
}

export const cartViewModel = new CartViewModel();
