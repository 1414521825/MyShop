import { GoodsItemModel } from "../../models/Goods/GoodsItemModel";
import { goodsService } from "../../services/GoodsService";
import { GoodsItemViewModel } from "./GoodsItemViewModel";

@ObservedV2
export class GoodsListViewModel {
  @Trace goodsList: GoodsItemViewModel[] = [];

  @Trace isLoading: boolean = false;       // 控制首屏/下拉刷新的加载动画
  @Trace isLoadingMore: boolean = false;   // 控制瀑布流底部“正在加载更多”的状态
  @Trace hasMore: boolean = true;          // 标记是否还有下一页数据
  @Trace isRefreshing : boolean = false;

  private currentPage: number = 1;

  // 加载商品列表
  async loadGoodsList(): Promise<void> {
    /*
     * 如果 getGoodsList() 抛异常，isLoading 永远卡在 true，列表空白，用户不知道发生了什么。
     * 所以使用try来进行获取资源
     * */
    this.isLoading = true;
    this.currentPage = 1;
    this.hasMore = true;
    try {
      const models: GoodsItemModel[] = await goodsService.getGoodsList();
      this.goodsList = models.map((model: GoodsItemModel) => new GoodsItemViewModel(
        model.id,
        model.goodsName,
        model.goodsPrice,
        model.goodsDesc,
        model.goodsImage
      ));
    } catch (err) {
      // 暂时 print 日志，后续加错误状态
      console.error('加载商品失败: ' + JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }
}