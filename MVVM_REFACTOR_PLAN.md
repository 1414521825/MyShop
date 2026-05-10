# MyShop MVVM 重构计划

> 目标：把当前项目从“页面能跑通”调整为“职责清晰、状态可控、后续能承载登录态、网络容错、购物车和拼团复杂业务”的 MVVM 结构。

---

## 1. 重构目标

这次重构不追求一次性做大模块化，也不先拆 HAR/HSP。当前目标是先在 `entry/src/main/ets` 内建立稳定的分层和数据流。

### 目标数据流

```text
View 用户事件
  -> ViewModel 暴露的方法
  -> Service 获取或保存数据
  -> Model / DTO 承载业务数据
  -> ViewModel 更新 @Trace 状态
  -> View 通过 @Param 渲染
```

### 分层职责

| 层 | 目录 | 职责 | 禁止事项 |
| --- | --- | --- | --- |
| Page | `pages/` | 路由入口、页面组装、创建或注入 ViewModel | 不写具体业务计算 |
| View | `views/` | UI 展示、用户事件上报、局部展示态 | 不直接 import 全局 ViewModel，不直接调用 Service |
| ViewModel | `viewmodels/` | UI 状态、交互逻辑、派生状态、请求状态 | 不写 ArkUI 组件，不依赖 View |
| Model | `models/` | 业务数据结构 | 不依赖 UI，不做页面状态管理 |
| Service | `services/` | 网络、本地存储、Mock 数据来源 | 不依赖 View，不操作 UI 状态 |
| Utils | `utils/` | 通用工具、日志、性能打点 | 不承载业务状态 |

### 组件分类

| 类型 | 例子 | 能否引用 ViewModel |
| --- | --- | --- |
| 页面组件 | `Index`、后续 `GoodsDetailPage` | 可以持有页面级 ViewModel |
| 业务组件 | `CartListView`、`StatisticsView` | 优先不引用；确有必要时只引用本 feature 的接口 |
| 共享组件 | 通用按钮、空态、加载态、价格文本 | 禁止引用 ViewModel，只能 `@Param + @Event` |

---

## 2. 当前代码问题清单

先解决这些基础问题，再继续做登录态和拼团。

| 问题 | 位置 | 影响 | 处理方式 |
| --- | --- | --- | --- |
| `GoodsItem` / `GoodsItemModel` / `GoodsItemViewModel` 混用 | `services/`、`views/`、`viewmodels/` | 类型不稳定，后续扩展容易乱 | 统一命名和职责 |
| `CartItem` / `CartItemModel` / `CartItemViewModel` 混用 | `views/Cart/`、`viewmodels/` | 购物车列表类型不一致 | 统一购物车项模型 |
| View 直接调用全局 `cartViewModel` | `views/GoodsDetailCard.ets` | 违反数据流，组件不可复用 | 改成 `@Event onAddCart` |
| `CartViewModel` 仍用深层 `@Computed` | `viewmodels/CartViewModel.ets` | 已知 V2 深层数组派生不可靠 | 改成显式 `@Trace` 派生字段 |
| `GoodsListViewModel` 有无效语句 | `viewmodels/GoodsListViewModel.ets` | 编译和可读性风险 | 删除 `const data = await GoodsItemModel` |
| 残留空文件 | `models/Goods/GoodsModel.ets` | 干扰认知 | 删除或补成真实模型 |
| `@Provider/@Consumer` 用作购物车事件通道 | `ShopCartTab`、`CartListItemView` | 层级隐式，调试成本高 | 父子链路改 `@Param + @Event` |
| 首页只有成功态 | `HomeTab`、`GoodsListViewModel` | 不像真实业务页面 | 补 loading / empty / error |

---

## 3. 目标目录结构

第一轮先不拆多 module，只整理单 HAP 内目录。

```text
entry/src/main/ets/
├── models/
│   ├── goods/
│   │   ├── GoodsItemModel.ets
│   │   └── GoodsSkuModel.ets
│   └── cart/
│       └── CartItemModel.ets
├── services/
│   ├── HttpClient.ets
│   ├── GoodsService.ets
│   └── CartService.ets
├── viewmodels/
│   ├── GoodsListViewModel.ets
│   ├── CartViewModel.ets
│   └── types/
│       └── RequestState.ets
├── views/
│   ├── goods/
│   ├── cart/
│   ├── common/
│   └── tabs/
├── pages/
│   └── Index.ets
└── utils/
    └── PerfTracker.ets
```

说明：

- 目录大小写统一，建议使用小写 feature 目录：`goods/`、`cart/`、`tabs/`。
- 第一轮可以先不移动所有文件，避免一次重构过大；但新增文件按目标结构放。
- 如果 DevEco 对路径大小写或现有 import 敏感，先保持现有目录，完成职责重构后再做目录整理。

---

## 4. 分阶段执行计划

### Phase 0：编译和类型基线

目标：先让现有代码类型明确、无明显残留。

- [x] 统一商品类型：确定 `GoodsItemModel` 是当前唯一商品数据类型。
- [x] 修正 `GoodsService` 中错误的 `GoodsItem` import 和构造。
- [x] 修正 `GoodsListItem`、`GoodsDetailCard`、`HomeTab` 的商品类型。
- [x] 统一购物车类型：确定 `CartItemViewModel` 或 `CartItemModel` 的使用边界。
- [x] 删除或修正 `GoodsModel.ets` 中的残留 `class Go`。
- [x] 删除 `GoodsListViewModel.loadGoodsList()` 中的无效语句。

验收：

- 首页商品列表能正常展示。
- 点击商品能打开详情卡片。
- 加入购物车后购物车列表能展示。
- 无明显类型名混乱。

### Phase 1：View 不直接改全局状态

目标：让 View 通过事件把用户意图交给上层。

重构前：

```text
GoodsDetailCard -> 直接 import cartViewModel -> addCartItem()
```

重构后：

```text
GoodsDetailCard -> @Event onAddCart(goods, count)
HomeTab / Page -> cartViewModel.addCartItem(goods, count)
```

任务：

- [x] `GoodsDetailCard` 删除 `cartViewModel` import。
- [x] `GoodsDetailCard` 增加 `@Event onAddCart`。
- [x] `HomeTab` 接收 `onAddCart`，调用购物车 ViewModel。
- [x] `GoodsDetailCard` 只负责数量展示、关闭、点击上报。

验收：

- `views/GoodsDetailCard.ets` 不再 import `viewmodels/CartViewModel`。
- 加购行为仍然可用。
- 商品详情卡片可以独立复用到详情页或推荐流。

### Phase 2：购物车派生状态显式化

目标：避开已知 V2 深层数组 `@Computed` 不可靠问题。

重构前：

```typescript
@Computed get totalPrice()
@Computed get isAllChecked()
@Computed get buyCount()
```

重构后：

```typescript
@Trace totalPrice: number = 0;
@Trace buyCount: number = 0;
@Trace isAllChecked: boolean = false;

private refreshDerived(): void {
  // 每次购物车突变后统一刷新
}
```

任务：

- [ ] `CartViewModel` 增加 `@Trace totalPrice`、`@Trace buyCount`、`@Trace isAllChecked`。
- [ ] 删除或停用购物车深层 `@Computed`。
- [ ] 在 `addCartItem`、`decreaseCartItem`、`removeCheckedItems`、`updateItemChecked`、`allCheckedChange` 末尾调用 `refreshDerived()`。
- [ ] 所有购物车突变只通过 `CartViewModel` 方法发生。
- [ ] 增加库存限制：数量不能超过 `stock`。

验收：

- 勾选商品后总价、结算数量、全选状态稳定更新。
- 加减数量后派生状态稳定更新。
- 删除已选后派生状态稳定更新。
- 不再依赖深层数组 `@Computed` 做核心业务状态。

### Phase 3：购物车组件通信改造

目标：减少隐式 `@Provider/@Consumer` 事件通道，优先使用显式参数和事件。

重构前：

```text
ShopCartTab @Provider('countChange')
CartListItemView @Consumer('countChange')
```

重构后：

```text
ShopCartTab
  -> CartListView({ onCountChange, onCheckedChange })
  -> CartListItemView({ onCountChange, onCheckedChange })
```

任务：

- [ ] `CartListView` 增加 `@Event onCountChange`、`@Event onCheckedChange`。
- [ ] `CartListItemView` 删除 `@Consumer('countChange')`。
- [ ] `CartListItemView` 删除 `@Consumer('updateChecked')`。
- [ ] `ShopCartTab` 通过参数把事件传下去。
- [ ] `StatisticsView` 保持 `@Param + @Event`。

验收：

- 打开任意子组件，能直接看出它依赖哪些数据和事件。
- 不需要搜索字符串 key 才能理解购物车行为。
- 购物车列表项仍支持勾选、加数量、减数量。

### Phase 4：请求状态标准化

目标：首页商品列表从“只有成功态”升级为真实业务页面状态。

新增类型：

```typescript
type RequestStatus = 'idle' | 'loading' | 'success' | 'empty' | 'error';

@ObservedV2
export class RequestState<T> {
  @Trace status: RequestStatus = 'idle';
  @Trace data?: T;
  @Trace errorMessage: string = '';
}
```

任务：

- [ ] 新增 `RequestState<T>`。
- [ ] `GoodsListViewModel` 使用 `RequestState<GoodsItemModel[]>` 或等价字段。
- [ ] `HomeTab` 展示 loading / empty / error / success。
- [ ] `GoodsService` 临时支持 mock 成功、空数组、抛异常三种模式。
- [ ] 错误态提供重试入口。

验收：

- Mock 成功时展示瀑布流。
- Mock 空数组时展示空态。
- Mock 异常时展示错误态和重试。
- `isLoading` 不会因为异常卡死。

### Phase 5：Service 和 Model 边界稳定

目标：让后续接真实网络、登录态、缓存时不需要推翻结构。

任务：

- [ ] `GoodsService` 只返回 Model 或 DTO，不返回 ViewModel。
- [ ] `CartService` 负责购物车本地 mock、后续持久化入口。
- [ ] ViewModel 负责把 Service 数据转成 UI 需要的状态。
- [ ] `HttpClient` 增加基础错误处理，不直接把 JSON parse 错误泄漏给页面。
- [ ] 规划后续 `AuthService`、`TokenStore`、`RequestInterceptor` 的位置。

验收：

- View 不 import Service。
- Service 不 import ViewModel。
- Model 不 import ArkUI。
- ViewModel 是 View 和 Service 之间唯一业务协调者。

---

## 5. 重构完成后的规则

### View 规则

- 可以持有局部展示状态：弹窗是否打开、当前输入值、临时选中项。
- 可以通过 `@Event` 上报用户行为。
- 不直接调用 Service。
- 不直接 import 全局业务 ViewModel。
- 不直接修改 `@Param` 对象的业务字段。

### ViewModel 规则

- 所有业务突变集中在 ViewModel 方法中。
- 派生状态如果跨数组、嵌套对象或多个字段，优先显式维护。
- 请求必须有 loading / success / empty / error。
- 失败要留下错误信息，页面能重试。

### Model 规则

- Model 是业务数据，不是 UI 状态。
- 需要响应式更新的 Model 字段才加 `@Trace`。
- 如果某个字段只在 ViewModel 内计算展示，不要硬塞进 Model。

### Service 规则

- Service 只负责数据来源和存储。
- Mock 数据也放 Service，不散落在 ViewModel 或 View。
- 后续接真实接口时，View 和大部分 ViewModel 不应大改。

---

## 6. 验收清单

完成第一轮 MVVM 重构后，用下面清单自查：

- [x] `GoodsDetailCard` 不再直接引用 `cartViewModel`。
- [ ] `CartListItemView` 不再使用 `@Consumer` 接收购物车事件。
- [ ] 购物车总价、结算数量、全选状态由 `CartViewModel` 显式维护。
- [ ] 首页商品列表有 loading / empty / error / success。
- [ ] `services/` 不 import `views/` 或 `viewmodels/`。
- [ ] `views/common/` 里的组件不 import ViewModel。
- [ ] 所有加购、减购、勾选、删除只通过 `CartViewModel` 方法修改。
- [ ] 能写出一条踩坑记录说明：这次重构解决了什么职责混乱。

---

## 7. 暂不做的事

为了避免第一轮重构失控，以下事情暂缓：

- 暂不拆 HAR/HSP。
- 暂不做完整登录态。
- 暂不做真实网络接口。
- 暂不做果园、砍价、分享海报。
- 暂不把所有组件一次性迁移目录。
- 暂不追求所有页面都完美符合最终目录结构。

第一轮只解决核心数据流和购物车稳定性。等这个闭环稳了，再进入登录态和网络层。
