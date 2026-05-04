import { GoodsItem } from "../models/Goods/GoodsItem";
import { goodsService } from "../services/GoodsService";

@ObservedV2
export class GoodsListViewModel {
  @Trace goodsList: GoodsItem[] = [];
  @Trace isLoading: boolean = false;
  @Trace isRefreshing : boolean = false;

  // 加载商品列表
  async loadGoodsList(): Promise<void> {
    /*
     * 如果 getGoodsList() 抛异常，isLoading 永远卡在 true，列表空白，用户不知道发生了什么。
     * 所以使用try来进行获取资源
     * */
    this.isLoading = true;
    try {
      this.goodsList = await goodsService.getGoodsList();
    } catch (err) {
      // 暂时 print 日志，后续加错误状态
      console.error('加载商品失败: ' + JSON.stringify(err));
    } finally {
      this.isLoading = false;
    }
  }
}