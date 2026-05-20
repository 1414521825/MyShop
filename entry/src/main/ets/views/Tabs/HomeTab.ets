import { cartViewModel } from '../../viewmodels/Cart/CartViewModel';
import { GoodsItemViewModel } from '../../viewmodels/Goods/GoodsItemViewModel';
import { GoodsListViewModel } from '../../viewmodels/Goods/GoodsListViewModel';
import { GoodsDetailCard } from '../GoodsDetailCard';
import GoodsListItem from '../GoodsListItem';

@ComponentV2
export struct HomeTab {
  @Local
  goodsListViewModel: GoodsListViewModel = new GoodsListViewModel();
  @Local
  selectedItem: GoodsItemViewModel | null = null;
  @Local
  selectedCount: number = 0;
  @Consumer('pageStack')
  pageStack: NavPathStack = new NavPathStack();
  private isJumpingLogin: boolean = false;

  aboutToAppear(): void {
    this.isJumpingLogin = false;
    this.loadGoodsList();
  }

  private async loadGoodsList(): Promise<void> {
    await this.goodsListViewModel.loadGoodsList();

    if (!this.goodsListViewModel.needLogin) {
      this.isJumpingLogin = false;
      return;
    }
    if (this.isJumpingLogin) {
      return;
    }

    this.isJumpingLogin = true;
    this.pageStack.pushPath({
      name: 'LoginPage'
    });
  }

  build() {
    Column() {
      if (this.goodsListViewModel.goodsListState.status === 'loading') {
        Text('加载中....')
      }
      else if (this.goodsListViewModel.goodsListState.status === 'empty') {
        Text('暂无商品')
      }
      else if (this.goodsListViewModel.goodsListState.status === 'error') {
        Text(this.goodsListViewModel.goodsListState.errorMessage)
        Button('重试')
          .onClick(() => {
            this.loadGoodsList();
          })
      }
      else {
        WaterFlow() {
          ForEach(this.goodsListViewModel.goodsList, (item: GoodsItemViewModel) => {
            FlowItem() {
              GoodsListItem({goodsItem: item, onItemClick: (goodsItem) => {
                this.selectedItem = goodsItem;
                this.selectedCount = 1;
              }})
            }
            .margin(2)
          }, (item: GoodsItemViewModel) => item.id)
        }
        .columnsTemplate('1fr 1fr')
        // .columnsGap(4)
        // .rowsGap(8)
        .layoutWeight(1)
      }
      // 商品详情（底部弹出）
      if (this.selectedItem !== null) {
        GoodsDetailCard({
          goodsItem: this.selectedItem,
          count: this.selectedCount,
          onCountChange: (count: number) => {
            this.selectedCount = count;
          },
          onClose: () => {
            this.selectedItem = null;
            this.selectedCount = 0;
          },
          onAddCart: (goods: GoodsItemViewModel, count: number) => {
            cartViewModel.addCartItem(goods, count);
          }
        });
      }
    }
    .width('100%')
    .height('100%')
  }
}
