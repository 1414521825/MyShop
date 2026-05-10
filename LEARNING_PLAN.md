# 拼多多风格商城 App — 鸿蒙学习计划

> **目标**：以电商业务项目驱动学习 HarmonyOS 客户端开发，掌握 ArkUI、ComponentV2 状态管理、MVVM 分层、网络容错、登录态、复杂列表、时间一致性、性能分析和稳定性治理。
> **角色**：即将入职拼多多鸿蒙客户端开发的应届生。
> **项目定位**：不是简单复刻拼多多页面，而是做一个具备真实客户端工程能力的电商练习项目。

---

## 学习方法论

- **业务闭环优先**：每个阶段都要产出可运行、可验证的小闭环，不只写孤立 API 示例。
- **知识点服务于工程能力**：页面能展示只是第一步，更重要的是弱网不崩、异常有兜底、状态不乱、列表不卡、问题能定位。
- **V2 优先，V1 对照**：学习项目以 ComponentV2 为主，但每个核心场景保留 V1/V2 对照认知。遇到 V2 边缘问题时，记录复现条件、降级方案和是否适合生产使用。
- **先深后广**：优先做深购物车、网络层、登录态、拼团倒计时、推荐流性能；果园、砍价、分享海报等运营玩法放到最后作为扩展实验。
- **每阶段必须复盘**：读文档、写代码、跑验证、做 V1/V2 对照、记录踩坑、补性能观察，缺一项就不算阶段完成。

---

## 每周学习节奏

每个阶段内部按以下节奏推进：

| 时间段 | 任务 |
| --- | --- |
| 周一~二 | 精读本阶段官方文档，把关键示例跑通，记录 V1/V2 差异 |
| 周三~五 | 完成核心业务闭环，先保证可运行，再补边界状态 |
| 周六 | 自查清单复盘、整理踩坑记录、补测试或手动验证用例 |
| 周日 | 观察拼多多 App 对应交互，拆解真实业务状态和技术实现 |

每阶段固定产出：

1. 一个可运行功能闭环。
2. 一份阶段自查结论。
3. 至少一条踩坑记录。
4. 一组 V1/V2 对照笔记。
5. 一次性能或稳定性观察。

---

## 贯穿全项目的五条主线

```text
MVVM 分层
  -> 登录态
  -> 网络容错
  -> 购物车 / SKU / 拼团
  -> 推荐流性能
  -> 可观测性和降级能力
```

### 主线一：MVVM 分层

目标不是目录看起来像 MVVM，而是形成稳定的数据流：

```text
View 用户事件
  -> ViewModel 方法
  -> Service / Repository
  -> Model / DTO
  -> ViewModel 更新 @Trace 状态
  -> View 通过 @Param 渲染
```

当前重构思路详见 [MVVM_REFACTOR_PLAN.md](MVVM_REFACTOR_PLAN.md)。

### 主线二：登录态和网络容错

登录态不是一个登录页，而是所有业务接口、路由守卫、Token 刷新、缓存清理和异常兜底的基础。

必须覆盖：

- AccessToken / RefreshToken 分开管理。
- 并发 401 只刷新一次 Token。
- 刷新失败时所有等待请求统一失败并跳登录。
- 退出登录清理 Token、用户信息、接口缓存、购物车本地缓存。
- 手机号、Token、用户 ID 等敏感信息日志脱敏。

### 主线三：复杂电商业务态

电商客户端最容易出问题的不是静态页面，而是业务状态组合。

| 模块 | 必练业务态 |
| --- | --- |
| 商品详情 | SKU 可选/不可选、库存不足、活动价、券后价 |
| 购物车 | 商品失效、库存不足、限购、价格变化、部分不可结算 |
| 订单 | 地址缺失、提交失败、价格二次确认、重试 |
| 拼团 | 倒计时过期、人数不足、成功/失败、前后台恢复 |
| 推荐流 | 分页失败、重复数据、乱序返回、空数据 |

### 主线四：性能和体验

性能不是最后才做的优化，而是每阶段都要观察。

- 启动速度：冷启动链路、延迟初始化。
- 页面打开速度：预拉数据、骨架屏、缓存。
- 列表流畅度：WaterFlow、分页、图片缓存、复用。
- 网络体验：请求去重、弱网重试、失败重试。
- 交互反馈：按钮状态、加载态、错误态、空态。

### 主线五：可观测性和降级

真实工程里，能复现、能定位、能降级比“理想写法”更重要。

固定记录模板：

```markdown
## V2 问题降级记录

**V2 写法**：
**触发问题**：
**最小复现条件**：
**V1/普通写法替代方案**：
**是否适合生产使用**：
```

---

## ComponentV2 装饰器速览

| V1 | V2 | 用途 | 学习重点 |
| --- | --- | --- | --- |
| `@State` | `@Local` | 组件内部私有状态 | 只能本地初始化，适合局部展示态 |
| `@Prop` | `@Param` | 父到子单向传参 | V2 传引用，不是深拷贝 |
| `@Link` | `@Param` + `@Event` | 父子双向同步 | 子组件只上报事件，父级统一改数据 |
| `@Observed` + `@ObjectLink` | `@ObservedV2` + `@Trace` | 类属性观测 | 需要刷新 UI 的字段才加 `@Trace` |
| `@Provide` / `@Consume` | `@Provider` / `@Consumer` | 跨层级共享 | 不要滥用成全局事件总线 |
| `@Watch` | `@Monitor` | 状态监听 | 适合副作用，不替代渲染状态 |
| 无 | `@Computed` | 计算属性 | 适合单层稳定依赖，深层数组要谨慎 |
| 无 | `@Once` | 只接收首次参数 | 列表项中稳定字段可用 |
| `@Reusable` | `@ReusableV2` | 组件复用 | API 18+，配合长列表验证性能 |
| 无 | `@Type` | 序列化类型标记 | 配合持久化和嵌套类 |

关键原则：

- `@Computed` 不迷信。购物车总价、全选、结算数量这类跨数组派生状态，优先在 ViewModel 中显式维护。
- `@Provider/@Consumer` 只用于真正跨层级共享。普通父子组件通信优先 `@Param + @Event`。
- `@Param` 对象不要在子组件中直接改业务字段，避免隐式修改父级数据源。

---

## 阶段 0：当前代码修正 + MVVM 重构基线（2-3 天）

### 学习目标

修正当前项目中类型、import、全局状态调用和购物车派生状态问题，为后续功能打基础。

### 重点任务

1. 统一 `GoodsItemModel` / `GoodsItemViewModel` / `GoodsItem` 的职责和命名。
2. 统一 `CartItemModel` / `CartItemViewModel` / `CartItem` 的职责和命名。
3. 删除或修正残留文件，如 `GoodsModel.ets`。
4. 删除 `GoodsListViewModel` 中无效语句。
5. `GoodsDetailCard` 不再直接 import 全局 `cartViewModel`，改为通过 `@Event onAddCart` 上报。
6. `CartViewModel` 显式维护 `totalPrice`、`buyCount`、`isAllChecked`。
7. 购物车列表项通信从 `@Provider/@Consumer` 改为显式 `@Param + @Event`。

### 验收标准

- 首页商品列表可展示。
- 点击商品可打开详情卡片。
- 加购后购物车可展示。
- 勾选、全选、加减数量后总价和结算数量稳定更新。
- View 不直接调用 Service 或全局业务 ViewModel。

### 自查清单

- [ ] `views/` 中是否还直接 import `cartViewModel`？
- [ ] 购物车派生状态是否还依赖深层数组 `@Computed`？
- [ ] 子组件依赖的数据和事件是否能从入参看出来？
- [ ] Service 是否仍然只负责数据来源？

---

## 阶段 1：项目骨架 + ArkUI + Navigation + MVVM（1.5 周）

### 学习目标

掌握 ArkUI 页面结构、`Navigation`、底部 Tab、页面组装、ViewModel 生命周期和组件通信。

### 鸿蒙知识点

| 知识点 | 说明 |
| --- | --- |
| `@ComponentV2` | V2 组件声明方式 |
| `Navigation` + `NavPathStack` | 页面跳转和路由栈管理 |
| `Tabs` / `TabContent` | 首页、分类、消息、购物车、个人中心 |
| `@Local` / `@Param` / `@Event` | 页面局部状态和父子通信 |
| `AbilityStage` / `UIAbility` | 应用生命周期基础 |
| `hilog` | 生命周期和关键行为日志 |

### 练手任务

1. 搭建 5 个 Tab 页壳子：首页、分类、消息、购物车、个人中心。
2. 用 `Navigation` 管理后续商品详情、登录页、确认订单页。
3. 首页展示商品列表，列表状态由 `GoodsListViewModel` 管理。
4. 商品卡片点击后通过事件通知页面打开详情卡片或详情页。
5. 抽出通用空态、加载态、错误态组件。
6. 用 `PerfTracker` 打点首页首次展示耗时。

### V1/V2 对照思考

- `@State` 可以外部初始化，`@Local` 不可以，这对组件职责有什么影响？
- V1 中 `@Prop` 深拷贝和 V2 中 `@Param` 传引用分别适合什么场景？
- `router.pushUrl` 和 `NavPathStack.pushPath` 在可维护性上有什么区别？

### 自查清单

- [ ] Tab 页面是否只负责组装，不做复杂业务计算？
- [ ] 商品卡片是否能独立复用？
- [ ] 页面跳转参数是否类型清晰？
- [ ] 首页是否具备 loading / empty / error / success？

---

## 阶段 2：网络层 + 请求状态 + 登录态（1.5 周）

### 学习目标

从 Mock 过渡到真实网络层思维，掌握统一请求状态、错误态、Token 管理、401 刷新队列和路由守卫。

### 鸿蒙知识点

| 知识点 | 说明 |
| --- | --- |
| `@ohos.net.http` | HTTP 请求基础 |
| `preferences` | 轻量持久化，适合学习 Token 存取 |
| Universal Keystore Kit | 了解敏感信息安全存储方向 |
| `TextInput` | 手机号、验证码输入 |
| 路由守卫 | 登录前拦截需要权限的页面 |

### 统一请求状态

```typescript
type RequestStatus = 'idle' | 'loading' | 'success' | 'empty' | 'error';

@ObservedV2
class RequestState<T> {
  @Trace status: RequestStatus = 'idle';
  @Trace data?: T;
  @Trace errorMessage: string = '';
}
```

### 练手任务

1. 封装 `HttpClient`，统一处理 JSON parse、状态码、网络错误。
2. `GoodsListViewModel` 使用 `RequestState<GoodsItemModel[]>`。
3. 实现登录页：手机号、验证码、获取验证码倒计时。
4. 实现 `AuthService`、`TokenStore`、`AuthViewModel`。
5. 实现 Token 注入、401 刷新、刷新失败跳登录。
6. 并发 401 时队列化，只允许一个刷新请求。
7. 退出登录时清理 Token、用户信息、缓存和购物车本地数据。
8. 敏感日志脱敏。

### V1/V2 对照思考

- 登录态用单例 ViewModel、`@Provider/@Consumer`、`AppStorageV2` 分别有什么利弊？
- `@Monitor` 适合监听登录态做副作用，还是适合作为页面渲染的数据来源？

### 自查清单

- [ ] 所有页面是否都有失败态和重试入口？
- [ ] 并发 401 是否只刷新一次 Token？
- [ ] Token 刷新失败后等待中的请求如何结束？
- [ ] 退出登录是否清理了业务缓存？
- [ ] 日志中是否打印了完整手机号或 Token？

---

## 阶段 3：商品详情 + SKU + 购物车复杂业务态（2 周）

### 学习目标

把购物车和商品详情从“能加购”做成接近真实业务的复杂状态练习。

### 鸿蒙知识点

| 知识点 | 说明 |
| --- | --- |
| `Swiper` | 商品图片轮播 |
| `Grid` | SKU 规格选择 |
| `@CustomDialog` | SKU 弹窗、价格变化确认 |
| `List` | 购物车列表 |
| `@ObservedV2` + `@Trace` | 商品、SKU、购物车项状态 |

### 练手任务

1. 商品详情页：图片轮播、标题、价格、SKU 选择、底部购买栏。
2. SKU 选择：颜色、规格组合；不可选规格置灰；库存不足禁止加购。
3. 购物车支持：勾选、全选、加减数量、删除已选。
4. 异常业务态：
   - 商品失效，置灰但保留在购物车。
   - 库存不足，数量自动降级。
   - 价格变化，结算前弹窗提示。
   - 部分商品不可结算。
5. 购物车派生状态由 ViewModel 显式维护：总价、结算数量、全选状态。
6. 加购、减购、勾选支持乐观更新；失败时回滚。

### V1/V2 对照思考

- SKU 多层嵌套对象用 V1 `@Observed/@ObjectLink` 和 V2 `@ObservedV2/@Trace` 的组件粒度会有什么不同？
- 哪些派生状态适合 `@Computed`，哪些应该在 ViewModel 中显式维护？

### 自查清单

- [ ] 子组件是否还直接修改 `@Param` 对象业务字段？
- [ ] 购物车所有突变是否都经过 `CartViewModel`？
- [ ] 价格变化、库存不足、商品失效是否都有 UI 兜底？
- [ ] 失败回滚是否会导致 UI 和数据不一致？

---

## 阶段 4：拼团核心 + 时间一致性（1.5-2 周）

### 学习目标

掌握拼团业务、服务端时间校准、倒计时精度、前后台恢复和活动过期兜底。

### 鸿蒙知识点

| 知识点 | 说明 |
| --- | --- |
| `setInterval` | 倒计时 tick，但不能作为真实时间源 |
| UIAbility 前后台生命周期 | 回到前台时刷新时间和活动状态 |
| `@Monitor` | 监听拼团状态变化触发副作用 |
| `@Computed` | 简单派生展示，如剩余人数 |
| 本地通知 | 拼团成功或即将过期提醒，作为了解项 |

### 练手任务

1. 定义 `GroupBuyModel`、`GroupMemberModel`、`GroupBuyViewModel`。
2. App 启动或进入拼团页时请求服务端时间，计算 `offset = serverTime - localTime`。
3. 倒计时使用 `serverEndTime - (Date.now() + offset)`。
4. 页面进入后台后停止无意义 UI tick，回到前台重新校准时间和状态。
5. 拼团状态覆盖：待成团、成功、失败、已过期。
6. 参团人数变化时触发提示或动画。
7. 活动过期、库存不足、人数不足时有明确 UI 兜底。

### V1/V2 对照思考

- 倒计时剩余秒数应该存在组件内还是 ViewModel 中？
- `@Monitor('groupBuy.status')` 和手动在请求成功后判断状态，分别适合什么场景？
- `Date.now()` 为什么不能直接作为活动真实时间？

### 自查清单

- [ ] 后台 10 秒再回来，倒计时是否仍然准确？
- [ ] 服务端时间 offset 什么时候重新校准？
- [ ] 活动过期时按钮、价格、文案是否同步变化？
- [ ] 拼团状态变化是否有唯一数据源？

---

## 阶段 5：推荐流 + 图片 + 列表性能（2 周）

### 学习目标

掌握电商首页/推荐流高频能力：瀑布流、分页、图片加载、列表复用、骨架屏、性能分析。

### 鸿蒙知识点

| 知识点 | 说明 |
| --- | --- |
| `WaterFlow` | 双列瀑布流 |
| `Refresh` | 下拉刷新 |
| `List.onReachEnd` / 滚动触底 | 加载更多 |
| `@ReusableV2` | 长列表组件复用，API 18+ |
| `@Once` | 列表项稳定字段首次初始化 |
| `freezeWhenInactive` | Tab 切走后冻结不可见页面 |
| DevEco Profiler | 帧率、CPU、内存观察 |

### 练手任务

1. 推荐流支持刷新、加载更多、分页失败重试。
2. 分页数据去重，处理重复商品和乱序返回。
3. 图片加载支持占位、失败图、缓存策略。
4. 对比 `ForEach`、`Repeat`、`@ReusableV2` 在长列表下的表现。
5. Tab 切走时冻结不可见页面，回来时校验数据是否过期。
6. 输出一次优化前后页面打开耗时和滚动流畅度对比。

### V1/V2 对照思考

- `@Reusable` 和 `@ReusableV2` 生命周期差异是什么？
- 哪些字段适合 `@Once`，哪些字段必须保持 `@Param` 同步？
- 列表项复用时，哪些状态必须重置？

### 自查清单

- [ ] 加载更多失败是否能重试？
- [ ] 重复商品是否被去重？
- [ ] 图片失败是否有兜底？
- [ ] 长列表滚动是否有明显卡顿？
- [ ] 复用列表项是否出现状态串项？

---

## 阶段 6：工程化 + 测试 + 稳定性（1 周）

### 学习目标

补齐真实客户端工程能力：测试、Mock、日志、性能 Trace、崩溃观察、模块化认知。

### 鸿蒙知识点

| 知识点 | 说明 |
| --- | --- |
| Hypium / Hamock | 单元测试和 Mock |
| `hiTraceMeter` | 耗时 Trace |
| `hilog` | 日志规范 |
| HiAppEvent | 崩溃和应用事件观察 |
| HAR / HSP / HAP | 模块化认知 |
| 混淆配置 | Release 基础配置了解 |

### 练手任务

1. 给 `CartViewModel` 写价格计算、全选、删除已选测试。
2. 给倒计时计算写服务端 offset 测试。
3. 给 Token 刷新队列写并发 401 测试或手动验证脚本。
4. 给关键业务事件统一日志 tag。
5. 用 `hiTraceMeter` 或 `PerfTracker` 记录启动、页面打开、接口耗时。
6. 人为制造一次崩溃，观察 HiAppEvent / HiLog 输出。
7. 写一页《模块职责说明》，说明当前为什么暂不拆 HAR/HSP。

### 自查清单

- [ ] ViewModel 核心逻辑是否能脱离 UI 验证？
- [ ] Mock 能否覆盖失败、空数据、弱网？
- [ ] 日志是否能辅助定位问题？
- [ ] 性能数据是否有优化前后对比？
- [ ] 是否理解 HAR/HSP/HAP 的基本区别？

---

## 阶段 7：可选扩展：果园、砍价、分享（3-5 天）

### 学习目标

把运营玩法作为补充实验，而不是主线工程目标。

### 可选任务

1. 多多果园简化版：Canvas 绘制树、浇水进度、阶段变化。
2. 砍价简化版：进度条、好友记录、动画反馈。
3. 分享：复制口令、系统分享、二维码。
4. 小组件了解：桌面展示拼团倒计时或活动入口。

### 控制范围

- 不占用主线时间。
- 不追求完整业务闭环。
- 只用于学习 Canvas、动画、分享、本地通知等鸿蒙能力。

---

## 各阶段性能 Pass 速查

| 阶段 | 性能和质量补充 |
| --- | --- |
| 阶段 0 | 修复状态更新不可靠点，建立可运行基线 |
| 阶段 1 | 首页首次展示耗时打点 |
| 阶段 2 | 接口耗时、错误率、401 队列日志 |
| 阶段 3 | 购物车操作响应速度、派生状态一致性 |
| 阶段 4 | 倒计时精度、前后台恢复准确性 |
| 阶段 5 | 推荐流滚动流畅度、图片加载、分页耗时 |
| 阶段 6 | 单测、Mock、崩溃观察、Trace 报告 |
| 阶段 7 | 动画帧率和内存观察 |

---

## 基础设施清单

| 基础设施 | 用途 | 阶段 |
| --- | --- | --- |
| `PerfTracker` | 启动、页面、接口耗时打点 | 阶段 1 起 |
| `RequestState<T>` | 页面 loading / success / empty / error | 阶段 2 |
| `HttpClient` | 统一网络请求、错误处理 | 阶段 2 |
| `AuthService` / `TokenStore` | 登录态和 Token 管理 | 阶段 2 |
| `CartService` | 购物车本地数据和后续持久化入口 | 阶段 3 |
| `TimeService` | 服务端时间校准 | 阶段 4 |
| `ImageLoader` | 图片占位、失败、缓存策略 | 阶段 5 |
| `MockConfig` | 成功、失败、空数据、弱网模拟 | 阶段 2 起 |

---

## V1 vs V2 核心差异总览

| 维度 | V1 | V2 | 工程判断 |
| --- | --- | --- | --- |
| 组件内部状态 | `@State` | `@Local` | V2 更强调状态来源清晰 |
| 父子传参 | `@Prop` 深拷贝 | `@Param` 引用 | V2 要避免子组件隐式改父数据 |
| 双向同步 | `@Link` | `@Param + @Event` | V2 更显式，适合 MVVM |
| 对象观测 | `@Observed + @ObjectLink` | `@ObservedV2 + @Trace` | V2 属性级观测更细 |
| 派生计算 | 手写 getter | `@Computed` | 深层数组不要迷信 `@Computed` |
| 状态监听 | `@Watch` | `@Monitor` | 适合副作用，不替代状态源 |
| 跨层共享 | `@Provide/@Consume` | `@Provider/@Consumer` | 谨慎使用，避免隐式依赖 |
| 组件复用 | `@Reusable` | `@ReusableV2` | 需要 API 18+ 和真实列表验证 |
| 冻结不可见组件 | 无 | `freezeWhenInactive` | 适合 Tab 和复杂页面 |
| 序列化类型 | 无 | `@Type` | 嵌套持久化时使用 |

---

## 关键提醒

1. 当前最重要的不是继续扩页面，而是把 MVVM 数据流、购物车状态和请求状态打稳。
2. `ComponentV2` 是学习主线，但真实项目可能大量存在 V1，必须保留迁移和降级意识。
3. Mock 数据优先，先把 UI、状态和异常跑通，再接真实接口。
4. 每个页面必须至少有 loading、empty、error、success。
5. 每个核心业务状态都要能回答：数据源在哪里？谁能修改？失败如何回滚？如何复现问题？
6. 踩坑记录继续保留，这是你后续面试、入职、复盘最有价值的材料。

---

## 进度标记

| 阶段 | 主题 | 周期 | 状态 | 完成日期 | 备注 |
| --- | --- | --- | --- | --- | --- |
| 阶段 0 | 当前代码修正 + MVVM 重构基线 | 2-3 天 | 进行中 | - | 见 `MVVM_REFACTOR_PLAN.md` |
| 阶段 1 | 项目骨架 + ArkUI + Navigation + MVVM | 1.5 周 | 待开始 | - | |
| 阶段 2 | 网络层 + 请求状态 + 登录态 | 1.5 周 | 待开始 | - | |
| 阶段 3 | 商品详情 + SKU + 购物车复杂业务态 | 2 周 | 待开始 | - | |
| 阶段 4 | 拼团核心 + 时间一致性 | 1.5-2 周 | 待开始 | - | |
| 阶段 5 | 推荐流 + 图片 + 列表性能 | 2 周 | 待开始 | - | |
| 阶段 6 | 工程化 + 测试 + 稳定性 | 1 周 | 待开始 | - | |
| 阶段 7 | 可选扩展：果园、砍价、分享 | 3-5 天 | 待开始 | - | |

---

## 踩坑记录

> 模板：每次解决一个问题花 2 分钟填一条。六个月后这比任何教程都有价值。

格式：

```markdown
## [日期] 问题简述

**现象**：（什么情况下发生了什么）
**排查过程**：（试了哪些方向、哪个方向排除了）
**根因**：（最终原因是什么）
**解法**：（怎么修的）
**标签**：#状态管理 / #路由 / #生命周期 / #网络 / #组件复用 / #性能
```

### 示例

```markdown
## 2026-04-28 @Param 修改对象属性导致父组件数据被意外篡改

**现象**：子组件内直接修改 `@Param item.title = 'xxx'` 后，回到列表页发现原始数据也变了
**排查过程**：打断点发现子组件和父组件拿的是同一个对象引用
**根因**：V2 的 @Param 传引用而非深拷贝（与 V1 @Prop 行为不同）
**解法**：子组件通过 @Event 通知父组件修改，由父组件统一更新数据源
**标签**：#状态管理 #ComponentV2
```

### 2026-05-02 ForEach keyGenerator 导致只渲染一项

**现象**：使用 `WaterFlow` + `ForEach` 渲染商品列表，数据源有 3 个商品，页面只显示最后一个。

**排查过程**：
1. 检查 `goodsList` 数据，确认 3 条数据已正确填充。
2. 检查 `ForEach` 的 `itemGenerator`，确认语法无误。
3. 锁定 `keyGenerator`：`(item) => item.toString()`。
4. 打印日志发现所有对象都返回 `"[object Object]"`。

**根因**：`ForEach` 依赖 key 追踪列表项。`GoodsItem` 未重写 `toString()`，所有对象 key 相同，ArkUI 认为它们是同一项，只保留最后一次渲染。

**解法**：给 `GoodsItem` 加 `id` 字段，keyGenerator 改用 `(item) => item.id`。

**标签**：#ForEach #列表渲染

---

### 2026-05-02 Button 小尺寸时文字不显示

**现象**：商品详情卡片中 28×28 的加减按钮只显示灰色背景，`+` / `-` 文字完全看不到。

**排查过程**：
1. 确认 `.fontColor(Color.White)` 和 `.backgroundColor(Color.Gray)` 已设置。
2. 尝试验证是否 Button 不支持 `.fontColor()`，换成 `Text` 组件正常显示。
3. 对比 `Text` 和 `Button` 的差异，发现 Button 有默认内边距。

**根因**：`Button` 默认有内边距（约 4-8vp），28×28 的按钮去掉内边距后文字区域所剩无几，被挤压到不可见。

**解法**：给 `Button` 加 `.padding(0)`，去掉默认内边距即可正常显示文字。

**标签**：#Button #样式

---

### 2026-05-03 Checkbox 闪烁 + 全选无效：`!!` 双向绑定与 `@Computed` 追踪链失效

**现象**：
1. 购物车列表项 Checkbox 点击后闪烁（选中→取消→选中来回跳）
2. 底部"全选"Checkbox 点击后无反应，无法选中
3. 底部统计数据（已选件数、总价）不随 Checkbox 变化更新

**排查过程**：
1. 先怀疑 `!!` + `onChange` 同时存在导致冲突，去掉 `!!` 后单列表勾选仍有问题。
2. 检查全选逻辑，确认 `allCheckedChange` 正确设置了每个 item 的 `checked`，但 UI 不更新。
3. 定位到统计栏用的 `@Computed` 依赖链问题：`@Computed` 中读 `this.cartViewModel.cartItemList` → 数组迭代 → 元素 `@Trace checked`。
4. 发现回调中用了裸 `cartViewModel`（模块 import）而非 `this.cartViewModel`（`@Local` 代理），`@Computed` 的依赖追踪与实际写入路径不一致。
5. 最终确认 V2 当前版本中 `@Computed` 通过 `@Local` → `@ObservedV2.@Trace` 数组 → 数组元素 `@Trace` 属性的深层链式追踪不可靠。

**根因**：
- **Bug 1**：`Checkbox.select(checked!!)` + `.onChange(() => checked = !checked)` 同存。`!!` 双向绑定自动切换一次，`onChange` 又手动切换一次，两次写入方向相反导致闪烁。
- **Bug 2**：`@Computed` 依赖链太长。`@Computed get isAllChecked()` 依赖 `@Local cartViewModel` → `@Trace cartItemList` 数组引用 → 数组元素 `@Trace checked`。当通过 CartViewModel 方法修改 `item.checked` 并替换 `cartItemList = [...cartItemList]` 时，`@Computed` 未能被正确触发重计算。回调中混用裸 import 和 `this.` 加剧了追踪不一致。

**解法**：
不再依赖 `@Computed` 做深层派生，改为在 ViewModel 上显式管理派生状态：

1. `CartViewModel` 加 `@Trace isAllChecked`、`@Trace buyCount`、`@Trace totalPrice` 三个一等字段。
2. 创建 `private refreshDerived()` 方法，在所有突变（add/remove/decrease/checked change）末尾手动更新这三个值。
3. `ShopCartTab` 删掉所有 `@Computed` / `@Monitor`，直接从 `this.cartViewModel.xxx` 读 `@Trace` 值。
4. Checkbox 二选一：要么 `!!` 不要 `onChange`，要么 `select(checked)` + `onChange(value)` 不要 `!!`。

**经验**：V2 的 `@Computed` 适合单层依赖（同组件内的 `@Local`/`@Param`）。跨 `@ObservedV2` + `@Trace` 数组的深层追踪不可靠时，宁愿在 ViewModel 上显式维护派生状态——可预测性 > 声明式优雅。

**标签**：#状态管理 #ComponentV2 #@Computed #Checkbox

---

### 2026-05-03 @Param 简单类型在子组件中不刷新（V2 框架边缘 Bug）

**现象**：
购物车底部统计栏中，`buyCount` 能正常更新显示，但 `totalPrice` 始终显示 0。两者都为 `@Local` → `@Param` 传递的 number 类型，赋值路径完全一致。

**排查过程**（多轮实验）：
1. 确认 ViewModel 中 `refreshDerived()` 计算正确（console 日志验证 buyCount=1, totalPrice=5999）
2. 改用 `@Monitor` 拷贝 ViewModel 值到组件 `@Local` → `@Monitor` 读到正确值但 `build()` 不重执行 → 确认 `@Monitor` 不触发重渲染
3. 事件回调中内联赋值 `@Local` → 不生效
4. **硬编码实验**：回调中直接 `this.totalPrice = 8888` → 仍不显示 → 排除 ViewModel 读值问题
5. **合并 Button 实验**：`Button(\`结算(${buyCount}) ￥${totalAmount}\`)` → 两个值都正确显示 ✅
6. **分离 Text 实验**：`Text(\`￥${totalAmount}\`)` → 总显示 0 ❌
7. **@Computed 实验**：子组件中用 `@Computed` 生成字符串 → 也不生效 ❌
8. **参数重命名**：`money` → `totalAmount`，加默认值 `= 0` → 无效

**根因**：
**三层条件叠加**才触发此 Bug：`@ComponentV2`（非 @Entry）+ `TabContent` 包裹 + `Stack` 内嵌的子组件中 `Text` 对 `@Param` 不响应。任一条件不满足，Text 均能正常更新。

最终实验验证：
- 最简 `@Entry` + `@Local` → `@Param` → Text → ✅ 正常
- `@ComponentV2` + TabContent + Stack → Text → ❌ 不更新
- 同层级 `Button` 始终正常更新（Button 内部渲染管线不同）

**NOT**：不是 `@ObservedV2` 跨代理问题、不是模板字符串问题、不是 `.toString()` 问题、不是 `@Provider/@Consumer` 回调上下文问题、不是 `layoutWeight` 布局约束问题。

**解法**：
将 `totalAmount` 和 `buyCount` 合并到同一个 `Button` 中展示（Button 在上述三层条件下不受影响）。

**教训**：
- 用**对照实验**逐层排除变量：硬编码值排除读值问题 → `@Entry` 最简测试排除框架 bug → 逐步加回 TabContent/Stack 定位条件组合。
- 排查方向不要停留在推测，每一步用实验结论驱动下一步。

**标签**：#Text #@Param #TabContent #V2渲染缺陷

---

### 踩坑列表

| 序号 | 日期 | 问题 | 标签 | 阶段 |
| --- | --- | --- | --- | --- |
| 1 | 2026-05-02 | ForEach key 相同导致只渲染一项 | ForEach;KeyGenerator | 1 |
| 2 | 2026-05-02 | Button 小尺寸文字不可见 | Button;样式 | 1 |
| 3 | 2026-05-03 | Checkbox 闪烁 + 全选无效 | 状态管理;@Computed;Checkbox | 1 |
| 4 | 2026-05-03 | Text 在 TabContent+Stack 中对 @Param 不响应 | Text;@Param;TabContent;渲染缺陷 | 1 |
| 5 | 2026-05-04 | 布局约束未解时 V2 跳过组件内容更新 | layoutWeight;SpaceBetween;内容跳过 | 1 |

---

### 2026-05-04 布局约束未解时 V2 跳过组件内容更新

**现象**：
`Button` 在外层 `Row(justifyContent: SpaceBetween)` 中使用 `.layoutWeight(1)` 时，按钮内容（模板字符串中的 buyCount 和 totalAmount）全部显示 0。换 `.width(240)` 后正常。

**根因**：
V2 中 `SpaceBetween` 布局需要先确定各子元素宽度再分配间距。子元素使用 `layoutWeight(1)` 时形成循环依赖——SpaceBetween 需要知道 Button 宽度才能布局，但 layoutWeight 需要知道可用空间才能计算宽度。V2 无法解决这一约束冲突，导致 Button 有效渲染宽度为 0，框架跳过内容更新。

**解法**：在 `SpaceBetween` 父容器中，子元素使用固定 `.width()` 替代 `.layoutWeight()`。

**标签**：#layoutWeight #SpaceBetween #布局约束冲突

> 最后更新：2026-05-10
