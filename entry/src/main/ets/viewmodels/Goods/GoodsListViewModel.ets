import { GoodsItemModel } from "../../models/Goods/GoodsItemModel";
import { goodsService } from "../../services/GoodsService";
import { RequestState } from "../common/RequestState";
import { GoodsItemViewModel } from "./GoodsItemViewModel";

@ObservedV2
export class GoodsListViewModel {
  @Trace goodsListState: RequestState<GoodsItemViewModel[]> =
    new RequestState<GoodsItemViewModel[]>();

  private currentPage: number = 1;

  get goodsList(): GoodsItemViewModel[] {
    if (this.goodsListState.data === undefined) {
      return [];
    }

    return this.goodsListState.data;
  }

  // 加载商品列表
  async loadGoodsList(): Promise<void> {
    this.goodsListState.loading();
    this.currentPage = 1;

    try {
      const models: GoodsItemModel[] = await goodsService.getGoodsList();
      const goodsList: GoodsItemViewModel[] = models.map(
        (model: GoodsItemModel): GoodsItemViewModel => {
          return GoodsItemViewModel.fromModel(model);
        });

      if (goodsList.length === 0) {
        this.goodsListState.empty();
        return;
      }

      this.goodsListState.success(goodsList);
    } catch (err) {
      this.goodsListState.error('商品列表加载失败');
    }
  }
}
