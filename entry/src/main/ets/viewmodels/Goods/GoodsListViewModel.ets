import { GoodsItemModel } from "../../models/Goods/GoodsItemModel";
import { goodsService } from "../../services/GoodsService";
import { HttpError } from "../../services/HttpClient";
import { RequestState } from "../common/RequestState";
import { GoodsItemViewModel } from "./GoodsItemViewModel";

@ObservedV2
export class GoodsListViewModel {
  @Trace goodsListState: RequestState<GoodsItemViewModel[]> =
    new RequestState<GoodsItemViewModel[]>();
  @Trace
  needLogin: boolean = false;

  get goodsList(): GoodsItemViewModel[] {
    if (this.goodsListState.data === undefined) {
      return [];
    }

    return this.goodsListState.data;
  }

  // 加载商品列表
  async loadGoodsList(): Promise<void> {
    this.needLogin = false;
    this.goodsListState.loading();

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
      if (err instanceof HttpError && err.statusCode === 401) {
        this.needLogin = true;
        this.goodsListState.error('登录已失效，请重新登录');
        return;
      }

      this.goodsListState.error('商品列表加载失败');
    }
  }
}
