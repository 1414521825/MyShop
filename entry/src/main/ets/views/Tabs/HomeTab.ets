import { GoodsItem } from '../../models/Goods/GoodsItem';
import { GoodsListViewModel } from '../../viewmodels/GoodsListViewModel'
import { GoodsDetailCard } from '../GoodsDetailCard';
import GoodsListItem from '../GoodsListItem';

@ComponentV2
export struct HomeTab {
  @Local
  goodsListViewModel: GoodsListViewModel = new GoodsListViewModel();
  @Local
  selectedItem: GoodsItem | null = null;
  @Local
  selectedCount: number = 0;

  aboutToAppear(): void {
    this.goodsListViewModel.loadGoodsList();
  }

  build() {
    Column() {
      WaterFlow() {
        ForEach(this.goodsListViewModel.goodsList, (item: GoodsItem) => {
          FlowItem() {
            GoodsListItem({goodsItem: item, onItemClick: (goodsItem) => {
              this.selectedItem = goodsItem;
              this.selectedCount ++;
            }})
          }
        }, (item: GoodsItem) => item.id)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(4)
      .rowsGap(8)
      .layoutWeight(1)

      // 商品详情（底部弹出）
      if (this.selectedItem !== null) {
        GoodsDetailCard({
          goodsItem: this.selectedItem,
          count: this.selectedCount,
          onCountChange: (id: string, count: number) => {
            this.selectedCount = count;
          },
          onClose: () => {
            this.selectedItem = null;
            this.selectedCount = 0;
          }
        });
      }
    }
    .width('100%')
    .height('100%')
  }
}