# 拼多多风格商城 App — 鸿蒙学习计划

> **目标**：以项目驱动学习鸿蒙（HarmonyOS）开发，掌握 ArkUI + ComponentV2 状态管理 + MVVM 架构。
> **角色**：客户端开发工程师（鸿蒙方向），应届生入职。
> **项目**：模仿拼多多核心功能的练手商城 App。

---

## 学习方法论

- **知识点驱动，而非代码驱动**：项目的目的是掌握鸿蒙技术栈，代码是该过程的产出物。
- **V2 优先**：以 ComponentV2（状态管理 V2）为主线，所有新代码默认使用 V2 装饰器。同时建立 V1 对照认知，因为实际项目可能仍是 V1。
- **每阶段循环**：读文档 → 动手写 → 刻意对比 V1/V2 → 自查清单复盘 → 进入下一阶段。
- **自查清单不为考核**，为帮助建立概念之间的关联。如果某个问题"大概知道但说不清楚"，就是需要回去深挖的知识盲区。

---

## 每周学习节奏

每个阶段（1.5-3 周）内部，按以下节奏循环：

| 时间段   | 任务                                                         |
| -------- | ------------------------------------------------------------ |
| 周一~二  | 精读本周目标的官方文档，**把文档里的示例代码跑通**（不要只看不写） |
| 周三~五  | 完成练手任务的核心部分，遇到问题优先查 API 参考、华为开发者社区 |
| 周六     | 自查清单复盘 + 查漏补缺 + 更新踩坑记录                        |
| 周日     | 休息或自由探索（如：看看拼多多 App 对应功能是怎么交互的，拆解技术实现思路） |

> **原则**：宁可周六复盘发现没学透、下周重新深挖，也不要赶进度跳过自查清单。

---

## 贯穿全项目的三条主线

```
       MVVM 分层架构
            ↕
登录态体系 ──→ HTTP 拦截器 ──→ 所有业务 ViewModel
            ↕
  缓存一致性 ──→ 时间校准 ──→ 倒计时组件 / 拼团 / 限时活动
```

三者互相咬合：
- **登录态**：数据通道的令牌，无它则所有业务接口走不通。
- **MVVM**：代码的组织骨架，决定数据如何流向 UI。
- **缓存一致性**：拼团这类强实时业务的命门，倒计时漂移 = 用户投诉。

配合**性能优化**贯穿所有阶段：
- 启动速度 → 冷启动链路精简 + 延迟初始化
- 页面打开速度 → 预拉数据 + 骨架屏
- 列表流畅度 → `@ReusableV2` + 图片缓存 + 分页预拉
- 网络层 → 请求合并 + 缓存策略分级

---

## ComponentV2 装饰器速览（核心地图）

| V1（旧）                    | V2（新）                        | 用途                      |
| --------------------------- | ------------------------------- | ------------------------- |
| `@State`                    | `@Local`                        | 组件内部私有状态，必须本地初始化 |
| `@Prop`                     | `@Param`                        | 父→子单向传参，传引用（非深拷贝） |
| `@Link`                     | `@Param` + `@Event`             | 父子双向同步，子通过回调通知父 |
| `@Observed` + `@ObjectLink` | `@ObservedV2` + `@Trace`        | 类属性深度观测，精准到属性级刷新 |
| `@Provide` / `@Consume`     | `@Provider` / `@Consumer`       | 跨层级状态共享 |
| `@Watch`                    | `@Monitor`                      | 状态变化监听，可获取变化前后值 |
| 无                          | `@Computed`                     | 计算属性，依赖不变时自动复用缓存 |
| 无                          | `@Once`                         | 搭配 `@Param`，仅首次初始化后不再同步 |
| `@Reusable`                 | `@ReusableV2`                   | 组件复用（API 18+） |
| 无                          | `@Type`                         | 配合 `PersistenceV2` 标记序列化类型 |

> **API 版本要求**：基础 V2（API 12+），`@ReusableV2`（API 18+）。
> **当前状态**：V2 为试用版，生产项目应评估稳定性后使用。

---

## 第一阶段：项目骨架 + MVVM + 性能基础设施（2 周）

### 学习目标
掌握 `@ComponentV2` 声明式 UI 范式、V2 基础装饰器、MVVM 分层、路由、网络请求。

### V2 知识点

| 知识点                     | 说明                                                         |
| -------------------------- | ------------------------------------------------------------ |
| `@ComponentV2`             | 替代 `@Component`，所有自定义组件默认用 V2                   |
| `@Local`                   | 替代 `@State`，组件内部状态，**必须本地初始化**，禁止外部传入 |
| `@Param`                   | 替代 `@Prop`，父→子单向传参，**传引用（非深拷贝）**            |
| `@Param` + `@Event`        | 替代 `@Link`，子组件通过 `@Event` 回调通知父组件修改数据源    |
| `@ObservedV2` + `@Trace`   | 替代 `@Observed` + `@ObjectLink`，类属性精准观测，**不再需要为每个子层级拆组件** |
| `@Computed`                | 计算属性 getter，依赖不变时自动复用缓存结果                   |

### 鸿蒙知识点

| 知识点           | 说明                                   |
| ---------------- | -------------------------------------- |
| ArkTS 类型系统   | `interface` / `class` / 泛型在 ArkTS 中的限制 |
| 页面路由         | `Navigation` + `NavPathStack`（推荐方案） vs 旧版 `router` |
| 网络请求         | `@ohos.net.http` 基本用法、HTTPS 证书配置 |
| 应用生命周期     | `AbilityStage` / `UIAbility` / `WindowStage` 回调顺序 |
| 数据持久化       | `@ohos.data.preferences` 轻量 KV 存储 |
| 日志             | `hilog` 打点，观察回调时序             |

### 前置阅读
- 华为开发者文档：**状态管理 V2** — `@ComponentV2`、`@Local`、`@Param`、`@Event`、`@ObservedV2`、`@Trace`、`@Computed`
- **Navigation 组件** 文档
- **UIAbility 组件生命周期** 文档

### 练手任务
1. 用 `@ComponentV2` + `Navigation` + 底部 TabBar 搭建 5 个 Tab 页壳子（首页/分类/消息/购物车/个人中心）
2. 定义 `@ObservedV2 class GoodsItem`，`@Trace` 标注需要响应式的字段，写商品列表页
3. 将列表状态抽到 `GoodsListViewModel`（同样 `@ObservedV2`），页面用 `@Local` 持有
4. **刻意练习 `@Param` + `@Event`**：列表页传选中商品给详情卡片，卡片内用 `@Event` 通知父组件修改数量
5. **刻意练习 `@Computed`**：实现购物车总价计算属性，观察依赖不变时跳过计算的日志
6. 封装网络请求工具类，Mock 一组商品 JSON 数据请求回来
7. 项目已建好的目录结构：

   ```
   entry/src/main/ets/
   ├── models/          # 数据模型（@ObservedV2 class）
   ├── viewmodels/      # ViewModel：状态持有 + 业务逻辑
   ├── views/           # 可复用 UI 组件（@ComponentV2，不含 @Entry）
   ├── pages/           # 页面级组件（路由目的地，@Entry 装饰）
   ├── services/        # 网络请求、本地存储
   └── utils/           # 工具函数、常量、类型定义
   ```

   > **pages/ vs views/ 约定**：`pages/` 放路由目的页面（用 `@Entry` 装饰），`views/` 放可复用的子组件（用 `@ComponentV2` 装饰，被页面组装使用）。比如商品卡片组件放 `views/`，首页、商品详情页放 `pages/`。

### V1→V2 对照思考
- `@Prop` 对复杂类型做**深拷贝**，`@Param` 传的是**引用**。这意味着子组件如果直接修改 `@Param` 对象的属性，父组件数据也会变——这带来了什么问题？如何规避？
- `@State` 可以从外部初始化，`@Local` 不可以。这迫使你把"需要外部传入"和"组件私有"分开——对架构设计是好事还是限制？

### 自查清单
- [ ] 能解释 `@State` 和 `@Local` 的本质区别吗？
- [ ] `@Param` 和 `@Prop` 的关键区别是什么？（提示：深拷贝 vs 引用）
- [ ] `@ObservedV2` 必须配合 `@Trace` 才生效，忘了加 `@Trace` 会怎样？
- [ ] `@Computed` 的缓存失效条件是什么？依赖非 `@Trace` 属性会怎样？
- [ ] `Navigation` 的 `pushPath` 和 `router.pushUrl` 有什么本质区别？
- [ ] `AbilityStage.onCreate` 和 `UIAbility.onCreate` 谁先执行？各自适合干什么？

---

## 第二阶段：登录态体系（1.5-2 周）

### 学习目标
掌握全局状态共享、`@Provider`/`@Consumer`、`@Monitor`、Token 管理、路由守卫。

### V2 知识点

| 知识点                     | 说明                                                         |
| -------------------------- | ------------------------------------------------------------ |
| `@Provider` / `@Consumer`  | 替代 `@Provide` / `@Consume`，跨层级共享状态。<br>V2 差异：`@Consumer` **必须本地初始化默认值**，`@Provider` **不允许从父组件初始化** |
| `@Monitor`                 | 替代 `@Watch`，监听状态变化，可获取变化前后值，支持深层监听     |
| `@ObservedV2` 单例模式     | `@ObservedV2 class` + `export const` 实现全局响应式单例        |

### 鸿蒙知识点

| 知识点           | 说明                                   |
| ---------------- | -------------------------------------- |
| 数据持久化       | `@ohos.data.preferences` 存取 Token     |
| HTTP 拦截器链     | Token 注入 → 401 检测 → 刷新重试 → 失败跳登录 |
| 路由守卫         | push 前拦截，未登录跳转登录页，登录后回跳   |
| 文本输入组件     | `TextInput` 手机号/验证码输入            |

### 前置阅读
- **@Provider / @Consumer** 文档（重点读 V1/V2 差异）
- **@Monitor** 文档
- **@ohos.data.preferences** API 参考
- **TextInput 组件** 文档

### 练手任务
1. 实现 `AuthViewModel`：`@ObservedV2 class` + `@Trace isLoggedIn` + `@Trace userInfo`，单例导出
2. 登录页：手机号输入框 + 验证码输入 + 获取验证码按钮（含 60 秒倒计时）
3. 登录成功后 Token 写入 `preferences`，App 重启自动恢复登录态
4. **刻意练习 `@Provider`/`@Consumer`**：根组件 `@Provider('auth')` 提供登录态，各 Tab 页用 `@Consumer('auth')` 消费
5. **刻意练习 `@Monitor`**：在需要感知登录状态的页面 `@Monitor('auth.isLoggedIn')` 监听变化做后续处理
6. 手写 HTTP 拦截器链：自动注入 Token → 遇到 401 自动刷新 → 刷新失败跳登录
7. 实现路由守卫：`NavPathStack.pushPath` 前检查登录态

### V1→V2 对照思考
- V1 `@Consume` 和 V2 `@Consumer` 的关键区别：V2 必须本地初始化默认值。这意味着消费方需要知道"没有 Provider 时的默认行为"——设计考量是什么？
- `@Provider` 和 `@Consumer` 通过字符串 key 匹配，**强依赖组件层级**。它和单例模式分别适用于什么场景？能否滥用？

### 自查清单
- [ ] `@Provider` 和单例模式各自的适用场景是什么？
- [ ] 如果同时有多个 `@Provider('auth')`，哪个生效？
- [ ] `@Monitor` 为什么能拿到变化前后的值，`@Watch` 为什么不行？
- [ ] HTTP 拦截器链中，并发请求同时遇到 401 时怎么处理 Token 刷新？（队列化）
- [ ] 路由守卫放在 `pushPath` 之前还是之后？为什么？
- [ ] `preferences` 的数据能否跨应用共享？安全性如何？

---

## 第三阶段：拼团核心 + 时间一致性（2.5-3 周）

### 学习目标
掌握 `@ObservedV2` 嵌套观测、`@Computed` 派生状态、`@Monitor` 深层监听、倒计时精度、前后台生命周期。

### V2 知识点

| 知识点                        | 说明                                                         |
| ----------------------------- | ------------------------------------------------------------ |
| `@ObservedV2` + `@Trace` 嵌套 | 嵌套类属性级精准观测，**V2 最大亮点**                         |
| `@Computed`                   | 计算"还差几人"、"剩余时间百分比"等派生状态                     |
| `@Monitor` 深层监听           | 监听 `'groupBuy.status'`，状态变化触发动画/通知                |
| `@CustomDialog`               | 自定义弹窗（SKU 选择等）                                      |

### 鸿蒙知识点

| 知识点             | 说明                                   |
| ------------------ | -------------------------------------- |
| 定时器精度         | `setInterval` 在页面后台时的行为，精度漂移问题 |
| 前后台生命周期     | `onBackground` / `onForeground`，回到前台时刷新数据 |
| 组件封装           | 自定义 `@ComponentV2` + `@BuilderParam` 插槽传 UI |
| 列表交互           | `Swiper`（商品图轮播）、`Grid`（SKU 规格选择） |
| 页面间传参         | `NavPathStack.pushPath` 带参，目标页 `onPageShow` 接收 |
| 状态恢复           | `onSaveState` / `onRestoreState` 异常销毁后状态恢复 |

### 前置阅读
- **@ObservedV2 嵌套类** 文档
- **@Monitor 深层监听** 文档
- **@CustomDialog** 文档
- **Swiper** / **Grid** 组件文档
- **UIAbility 前后台生命周期** 文档
- **onSaveState / onRestoreState** 文档

### 练手任务
1. 商品详情页：`Swiper` 轮播 + SKU `Grid` 选择 + `@CustomDialog` 弹窗选规格 + 底部固定购买栏
2. **重点：`@ObservedV2` 嵌套拼团模型**

   ```typescript
   @ObservedV2
   class GroupBuy {
     @Trace groupId: string = '';
     @Trace status: 'pending' | 'success' | 'failed' = 'pending';
     @Trace endTime: number = 0;    // 服务端截止时间戳
     @Trace members: Member[] = []; // 参团人列表
     @Trace requiredCount: number = 2;
     @Trace @Type(Member) leader: Member = new Member();
   }

   @ObservedV2
   class Member {
     @Trace name: string = '';
     @Trace avatar: string = '';
   }
   ```

   验证：修改 `members[0].name` 是否触发 UI 更新？为什么？（提示：数组元素观测机制）

3. **刻意练习 `@Computed` 派生状态**

   ```typescript
   @Computed
   get remainCount(): number {
     return this.groupBuy.requiredCount - this.groupBuy.members.length;
   }
   @Computed
   get remainSeconds(): number {
     return this.groupBuy.endTime - (Date.now() + this.timeOffset);
   }
   @Computed
   get progressPercent(): number {
     return (this.groupBuy.members.length / this.groupBuy.requiredCount) * 100;
   }
   ```

4. **刻意练习 `@Monitor` 深层监听**

   ```typescript
   @Monitor('groupBuy.status')
   onStatusChange(monitor: IMonitor) {
     const before = monitor.value()?.before;  // 'pending'
     const now = monitor.value()?.now;        // 'success'
   }
   @Monitor('groupBuy.members.length')
   onMemberJoin(monitor: IMonitor) {
     // 有人参团时的动画/提示
   }
   ```

5. 封装倒计时组件 `CountdownComponent`，接收 `endTime: number`（服务端时间戳），内部每秒 tick + 时间偏移校准
6. **时间校准**：App 启动时请求一次服务端时间，计算 `offset = serverTime - localTime`，倒计时用 `serverEndTime - (Date.now() + offset)`。思考：offset 什么时候该重新校准？
7. 开团/参团的完整购买流程（下单即可，不涉及真实支付）
8. 页面切到后台 10 秒再回来，倒计时是否正确？`@Monitor` 没触发但数据可能已过期——怎么补救？

### V1→V2 对照思考
- V1 时代，`@Observed` + `@ObjectLink` **必须把子对象拆分到独立组件**才能精准更新。V2 的 `@ObservedV2` + `@Trace` 直接做到了属性级精准刷新——这对你的组件粒度设计有什么影响？
- `@Monitor` 可以深层监听 `'groupBuy.members.0.name'`，但监听太细会有什么问题？

### 自查清单
- [ ] `@ObservedV2` 嵌套类如果不加 `@ObservedV2`，只给属性加了 `@Trace`，能观测到吗？
- [ ] `@Computed` 的缓存存在组件哪里？什么时候重建？
- [ ] 时间校准的 offset 为什么不能只获取一次？
- [ ] `setInterval` 在页面进入后台后会怎样？回来后时间偏了怎么修正？
- [ ] 倒计时的源应该存在组件内还是 ViewModel 里？为什么？
- [ ] 页面 A→B→C，C 修改了拼团状态，回到 A 时怎么刷新？
- [ ] 鸿蒙生命周期和 Android Activity 生命周期有什么异同？

---

## 第四阶段：推荐流 + 社交裂变（2-3 周）

### 学习目标
掌握 `@ReusableV2` 组件复用、`@Once` 静态内容优化、`freezeWhenInactive` 组件冻结、瀑布流、图片缓存、系统分享。

### V2 知识点

| 知识点                        | 说明                                                         |
| ----------------------------- | ------------------------------------------------------------ |
| `@ReusableV2` + `@ComponentV2` | 组件复用（API 18+），四个生命周期：`aboutToAppear` → `aboutToRecycle` → `aboutToReuse` → `aboutToDisappear`。<br>`aboutToReuse` **无入参**（与 V1 `@Reusable` 不同），状态重置由 V2 装饰器自动完成 |
| `@Once`                        | 搭配 `@Param`，首次接收外部值后不再同步，且可本地修改<br>适用场景：列表项中不变的字段（ID、封面图 URL） |
| `freezeWhenInactive`           | `@ComponentV2({ freezeWhenInactive: true })`，组件不可见时冻结数据更新 |
| `@StorageLink` / `@StorageProp` | App 全局存储（V2 场景下的位置）                               |

### 鸿蒙知识点

| 知识点         | 说明                                   |
| -------------- | -------------------------------------- |
| 瀑布流         | `WaterFlow` 组件（4.0+）                |
| 下拉刷新       | `Refresh` 组件 + `onRefresh`             |
| 加载更多       | `List.onReachEnd` 或滑到底部触发         |
| 图片缓存       | `Image` 组件 + 渐进式加载 + 三级缓存策略   |
| 系统分享       | `@ohos.share` / `systemShare`           |
| 剪贴板         | `@ohos.pasteboard` 复制邀请口令          |
| 二维码         | `QRCode` 组件生成邀请码                  |
| 响应式布局基础 | `@ohos.mediaquery`                       |

### 前置阅读
- **@ReusableV2** 文档（四个生命周期 + 状态重置规则）
- **@Once** 文档
- **freezeWhenInactive** 文档
- **WaterFlow** / **Refresh** 组件文档
- **@ohos.pasteboard** 文档
- **系统分享** 文档

### 练手任务
1. 双列瀑布流推荐页：`WaterFlow` + 下拉刷新 + 上滑加载更多
2. **重点：`@ReusableV2` + `@ComponentV2` 实现列表项复用**

   ```typescript
   @ReusableV2
   @ComponentV2
   struct GoodsWaterfallItem {
     @Param @Once goodsId: string = '';   // 不变，仅初始化一次
     @Param @Once coverUrl: string = '';  // 不变
     @Param title: string = '';           // 可能变，保持同步
     @Param price: number = 0;            // 可能变
     @Event onItemClick: (id: string) => void;
   }
   ```

3. **对比实验**：同一列表项加不加 `@ReusableV2` 的帧率差异（DevEco Profiler 观测）
4. **刻意练习 `@Once`**：哪些字段用 `@Once`？哪些保持 `@Param` 同步？判断依据是什么？
5. **刻意练习 `freezeWhenInactive`**：Tab 切走时冻结不可见页面，回来时解冻
6. 图片渐进式加载：先展示缩略图/模糊图，原图加载完成后替换
7. 页面预拉：列表滑动时预取商品详情数据到内存 Map，点击时秒开（思考：什么时候触发预拉最合适？滑到第几项开始？）
8. 拼团邀请页：生成邀请海报（`QRCode` + 文字组合）+ 复制口令到剪贴板 + 调用系统分享面板
9. 首页多接口请求合并为一个批量请求

### V1→V2 对照思考
- V1 `@Reusable` 的 `aboutToReuse` **有入参**，V2 `@ReusableV2` 的 `aboutToReuse` **无入参**。V2 怎么解决复用时的数据刷入问题？这背后体现了什么设计思路？
- `@ReusableV2` 样式**默认隔离**，V1 样式**默认继承**——有什么区别？实际开发中哪个更容易出问题？

### 自查清单
- [ ] `@ReusableV2` 组件复用时，`@Local` 的值会重置吗？`@Param @Once` 呢？
- [ ] `aboutToRecycle` 和 `aboutToDisappear` 的区别是什么？各适合释放什么资源？
- [ ] `freezeWhenInactive` 冻结的是什么？和直接 `if` 隐藏有什么区别？
- [ ] `WaterFlow` 的 `columnsTemplate` 和 `columnsGap` 怎么配置？Item 高度不一怎么处理？
- [ ] 瀑布流滑到第几项开始预加载下一页？为什么是这个数字？
- [ ] 图片缓存的 Key 应该怎么设计？URL 直接当 Key 有什么问题？
- [ ] `@StorageLink` 和 `@Provider` 的区别是什么？什么时候用哪个？

---

## 第五阶段：游戏化运营（2-3 周）

### 学习目标
掌握 `@ObservedV2` 深嵌套游戏状态、`@Monitor` 触发动画、Canvas 绘制、`@Type` 序列化、本地通知。

### V2 知识点

| 知识点                     | 说明                                                         |
| -------------------------- | ------------------------------------------------------------ |
| `@ObservedV2` 深嵌套       | 果树 → 阶段 → 所需水滴，属性级精准观测                         |
| `@Computed`                | 计算成熟度百分比、是否可收获                                   |
| `@Monitor` 触发动画        | 监听阶段变化 → 触发对应动画                                    |
| `@Type`                    | 配合 `PersistenceV2`，标记类属性类型用于序列化/反序列化<br>避免序列化时类信息丢失 |

### 鸿蒙知识点

| 知识点         | 说明                                   |
| -------------- | -------------------------------------- |
| 属性动画       | `animateTo` 显式动画                   |
| 隐式动画       | `.animation()` 属性动画                 |
| Canvas 绘制    | `Canvas` 组件绘制果树、进度等            |
| 振动反馈       | `@ohos.vibrator`                        |
| 本地通知       | `@ohos.notification` 拼团成功/果实成熟通知 |
| 关系型数据库   | `@ohos.data.relationalStore`（RDB）     |
| 音效           | `@ohos.multimedia.audio` 短音效播放      |

### 前置阅读
- **动画**：`animateTo`、属性动画、`TransitionEffect`
- **Canvas 组件** 文档
- **@ohos.notification** 文档
- **@ohos.data.relationalStore** 文档
- **@Type** 文档

### 练手任务
1. 多多果园简化版：Canvas 绘制一棵树 + 浇水按钮 + 进度条 + 浇水动画
2. **重点：`@ObservedV2` 深嵌套游戏状态**

   ```typescript
   @ObservedV2
   class TreeStage {
     @Trace name: string = '种子';      // 种子→幼苗→开花→结果
     @Trace iconIndex: number = 0;
     @Trace waterNeeded: number = 100;
   }

   @ObservedV2
   class OrchardState {
     @Trace currentWater: number = 0;
     @Trace @Type(TreeStage)
     stage: TreeStage = new TreeStage();
     @Trace tasks: Task[] = [];
   }
   ```

   验证：直接修改 `orchard.stage.name = '幼苗'` 能否触发 UI 更新？

3. **刻意练习 `@Computed` 游戏派生状态**

   ```typescript
   @Computed
   get progressPercent(): number {
     return this.orchard.currentWater / this.orchard.stage.waterNeeded * 100;
   }
   @Computed
   get isHarvestable(): boolean {
     return this.orchard.stage.name === '结果' && this.progressPercent >= 100;
   }
   ```

4. **刻意练习 `@Monitor` 触发动画**

   ```typescript
   @Monitor('orchard.stage.name')
   onStageChange(monitor: IMonitor) {
     const prev = monitor.value()?.before;
     const curr = monitor.value()?.now;
     if (prev === '开花' && curr === '结果') {
       // 触发结果动画 / 粒子效果
     }
   }
   ```

5. 任务列表：每日签到、浏览商品 N 秒、分享拼团等任务获取水滴
6. 果树状态通过 `@Type` + `PersistenceV2` 持久化到 `relationalStore`，App 杀进程后恢复
7. 定时通知：果实成熟时发本地通知
8. 砍价简化版：动画进度条从 100% 逐步减少，展示好友砍价记录列表，带入场动画

### V1→V2 对照思考
- `@Type` 的作用是什么？如果不加 `@Type`，序列化再反序列化后 `@ObservedV2` 类会丢失什么？
- `@Monitor` 监控 `'orchard.stage.name'` 和 `'orchard.stage'` 的触发范围有什么不同？哪个更高效？

### 自查清单
- [ ] `animateTo` 和 `.animation()` 的调用时机有什么区别？
- [ ] Canvas 坐标系是怎样的？如何绘制曲线/圆弧？
- [ ] `relationalStore` 和 `preferences` 的适用场景分别是什么？
- [ ] 本地通知需要什么权限？用户关闭通知权限后怎么兜底？
- [ ] `@Monitor` 监控 `'orchard.stage.name'` 和 `'orchard.stage'` 的触发范围有什么不同？

---

## 第六阶段：收尾整合 + V1/V2 迁移认知（1-2 周）

### 学习目标
性能分析、`@ReusableV2` + `Repeat` 虚拟列表、响应式布局、V1/V2 混用规则、迁移策略。

### V2 知识点

| 知识点           | 说明                                   |
| ---------------- | -------------------------------------- |
| V1/V2 混用规则   | 父 V2 可含 V1/V2 子组件；父 V1 可含 V1/V2 子组件<br>`@ReusableV2` 子组件**只能被 V2 父组件使用** |
| `Repeat` 虚拟列表 | 与 `@ReusableV2` 配合，超长列表性能优化  |

### 鸿蒙知识点

| 知识点         | 说明                                   |
| -------------- | -------------------------------------- |
| 性能打点       | `hiTraceMeter` 追踪耗时                 |
| 内存分析       | DevEco Studio Profiler（Memory / CPU）  |
| 帧率监控       | 开发者选项 GPU 呈现模式                 |
| 代码混淆       | HAP 编译混淆配置                        |
| 响应式布局     | `@ohos.mediaquery` 断点系统适配平板     |

### 前置阅读
- **hiTraceMeter** 文档
- DevEco Studio 性能分析工具文档
- **响应式布局** 文档
- **V1/V2 混用** 官方说明

### 练手任务
1. 给项目加启动耗时打点（各个生命周期节点），输出完整链路报告
2. DevEco Profiler 跑一遍所有页面，找内存泄漏点和过度渲染
3. 整体走查：哪些场景该用 `@Once`？哪些该加 `freezeWhenInactive`？哪些可以加骨架屏？哪些可以预拉？——自己列清单，逐项改进
4. 简单适配平板横屏布局（媒体查询）
5. **V1/V2 混合项目认知**：新建一个测试页，故意同时使用 `@Component` 和 `@ComponentV2`，观察编译器的警告/报错。理解混用规则表
6. 对比优化前后的启动耗时和页面打开耗时，形成一份小结
7. 如果让你维护一个 V1 老项目，你会从哪个装饰器开始逐步迁移到 V2？写一份迁移策略

### 自查清单
- [ ] 为什么 `@ReusableV2` 限定只能 V2 父组件使用？
- [ ] 启动耗时中，哪些可以并行，哪些必须串行？
- [ ] 鸿蒙的响应式布局和 Android 的有什么区别？
- [ ] 能画一张图说明"一个 V2 组件的完整生命周期 + 各装饰器作用时机"吗？
- [ ] 如果让你维护一个 V1 老项目，迁移策略是什么？

---

## 各阶段性能 Pass 速查

| 阶段     | 完成功能后追加的性能优化                                       |
| -------- | ------------------------------------------------------------ |
| 第一阶段 | 启动耗时打点埋点框架搭建 + SDK 延迟初始化（InitScheduler）      |
| 第二阶段 | 冷启动链路完整打点 + InitScheduler 生效验证                    |
| 第三阶段 | 页面预拉数据（详情页秒开） + 骨架屏 + 倒计时精度测试            |
| 第四阶段 | `@ReusableV2` 列表复用 + 图片三级缓存 + 分页预拉 + `freezeWhenInactive` |
| 第五阶段 | 动画帧率监控 + 内存泄漏检测（游戏状态持久化的引用管理）          |
| 第六阶段 | 全量性能 Review + 优化前后对比 + 跑分                          |

---

## 性能基础设施清单（第一阶段搭建）

| 基础设施        | 用途                             | 对应 V2/鸿蒙能力               |
| --------------- | -------------------------------- | ----------------------------- |
| `PerfTracker`   | 启动/页面/接口耗时打点            | `hiTraceMeter` + `hilog`       |
| `ImageLoader`   | 图片三级缓存（内存→磁盘→网络）     | `Image` 组件 + 自定义缓存策略    |
| `CacheManager`  | 接口缓存策略框架                  | 按需设计（memory/disk/preferences） |
| `PreloadManager`| 页面预拉 + 接口预取               | 内存 Map + `onVisibleAreaChange` |
| `InitScheduler` | SDK 分批延迟初始化                | 首帧前 → 首帧后空闲 → 按需      |

---

## V1 vs V2 核心差异总览

| 维度             | V1                                        | V2                                                    |
| ---------------- | ----------------------------------------- | ----------------------------------------------------- |
| 观测粒度         | 组件级（@ObjectLink 必须拆子组件）         | 属性级（@Trace 精准到字段）                            |
| 对象观测         | @Observed + @ObjectLink                    | @ObservedV2 + @Trace                                  |
| 父子双向同步     | @Link                                     | @Param + @Event（更显式）                              |
| 计算属性         | 无（只能手写 getter 每次都算）             | @Computed（自动缓存，依赖不变不重算）                   |
| 状态监听         | @Watch（仅一层，无变化前后值）             | @Monitor（深层监听，有变化前后值）                      |
| 跨层级共享       | @Provide/@Consume                         | @Provider/@Consumer（@Consumer 必须本地初始化默认值）   |
| 组件复用         | @Reusable（aboutToReuse 有入参，样式默认继承） | @ReusableV2（aboutToReuse 无入参，样式默认隔离，API 18+） |
| 组件冻结         | 无                                        | freezeWhenInactive                                    |
| 仅初始化一次     | 无                                        | @Once                                                 |
| 序列化类型标记   | 无                                        | @Type                                                 |

---

## 关键提醒

1. **V2 当前为试用版**（华为官方标注），生产项目需评估稳定性。但作为学习者，从 V2 切入理解设计理念，回头再看 V1 会觉得更简单。
2. **V1 和 V2 的根本区别**：V1 是"组件级观测"，V2 是"属性级观测"。这直接影响了组件粒度的设计方式。
3. **`@ReusableV2` 需要 API 18+**，检查 DevEco Studio 和模拟器版本是否满足。
4. **每阶段产出可运行的 HAP**，不要光写不跑。第一天就要确保 DevEco Studio + 模拟器/真机环境 OK。
5. **Mock 数据优先**，先不纠结后端，用本地 JSON 把 UI 和交互跑通。
6. **关注鸿蒙特有 API**：分布式能力、元服务卡片（桌面小组件展示拼团倒计时），这些在面试或工作中会是加分项。

---

## 进度标记

| 阶段   | 主题                   | 周期     | 状态      | 完成日期 | 备注 |
| ------ | ---------------------- | -------- | --------- | -------- | ---- |
| 第一阶段 | 项目骨架 + MVVM + V2   | 2 周     | ⏳ 待开始 | —        |      |
| 第二阶段 | 登录态体系             | 1.5-2 周 | ⏳ 待开始 | —        |      |
| 第三阶段 | 拼团核心 + 时间一致性   | 2.5-3 周 | ⏳ 待开始 | —        |      |
| 第四阶段 | 推荐流 + 社交裂变       | 2-3 周   | ⏳ 待开始 | —        |      |
| 第五阶段 | 游戏化运营             | 2-3 周   | ⏳ 待开始 | —        |      |
| 第六阶段 | 收尾整合 + 迁移认知     | 1-2 周   | ⏳ 待开始 | —        |      |

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
**V2 状态管理存在已知的不稳定因素（官方声明"still under development"）。子组件中 `@Param` 简单类型在不同 UI 组件中的响应不一致**——Button 对 `@Param` 变化的检测比 Text 更可靠。

官方文档明确指出：
> "using @Event to change the value of the parent component takes effect immediately. However, the process of synchronizing the change from the parent component to the child component is **asynchronous**."

事件回调中修改父组件 `@Local` → 子组件 `@Param` 的同步是异步的，同一渲染帧内可能还未完成。

同时：**子组件（`@ComponentV2`）中的 `@Computed` 不追踪 `@Param` 变化**——`@Computed` 设计上用于追踪 `@Local` 和 `@Trace`，官方从不在子组件中使用 `@Computed`。

**解法**（两种可选）：
1. **父组件 @Computed 格式化**：在父组件（有 `@Local` 可直接追踪）中用 `@Computed` 把值拼接成字符串，子组件只接收和展示最终字符串。
2. **显示合并**：把多个 `@Param` 值放在同一个 Button/UI 元素中展示，利用能刷新的那个值拖拽另一个一起更新。

**教训**：
- V2 仍为试用版，遇到违反直觉的行为不要只怀疑自己代码——可能是框架限制。
- `@Computed` 放在**数据源所在组件**（有 `@Local`），不放在子组件。
- `@Monitor` 可用作调试工具（验证值是否正确同步），但不能依赖它触发 UI 重渲染。
- 排查 `@Param` 不刷新问题时，用硬编码值对照实验可快速排除干扰因素。
- 子组件尽量保持"纯展示"：父组件做数据格式化，子组件只接收最终结果。

**标签**：#状态管理 #@Param #V2边缘Bug #异步同步

---

### 踩坑列表

| 序号 | 日期       | 问题                           | 标签              | 阶段 |
| ---- | ---------- | ------------------------------ | ----------------- | ---- |
| 1    | 2026-05-02 | ForEach key 相同导致只渲染一项  | ForEach;KeyGenerator | 1    |
| 2    | 2026-05-02 | Button 小尺寸文字不可见         | Button;样式           | 1    |
| 3    | 2026-05-03 | Checkbox 闪烁 + 全选无效        | 状态管理;@Computed;Checkbox | 1    |
| 4    | 2026-05-03 | @Param 数字在 Text 中不刷新     | @Param;异步同步;V2边缘Bug | 1    |

---

> 最后更新：2026-04-28
