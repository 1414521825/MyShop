# MyShop 后续工作接续文档

> 用途：上下文压缩或重新开启会话后，优先阅读本文，再结合 `LEARNING_PLAN.md` 和 `MVVM_REFACTOR_PLAN.md` 继续推进。

## 当前定位

这是一个用于学习 HarmonyOS 客户端开发的仿拼多多电商项目。当前重点不是堆页面，而是通过真实电商业务练习：

- ArkUI / ComponentV2 状态管理
- MVVM 分层和数据流
- 网络层、请求状态、登录态、Token 存储
- 商品、购物车、订单、拼团等复杂业务状态
- 列表性能、异常兜底、可维护工程结构

## 已完成的关键进展

### 1. MVVM 基础方向已确定

当前采用的主线是：

```text
View 用户事件
  -> ViewModel 方法
  -> Service / Repository
  -> Model
  -> ViewModel 更新 @Trace 状态
  -> View 渲染
```

现阶段先不引入 DTO，除非后续接入真实后端或接口结构明显不稳定。

当前学习结论：

- Model 可以是普通业务数据类，不必默认加 `@ObservedV2`。
- ViewModel 承载 UI 可观察状态，适合加 `@ObservedV2` / `@Trace`。
- Service 可以使用 Model，但不应该依赖 ViewModel 或 UI。
- View 尽量通过 `@Param + @Event` 和 ViewModel 交互，不直接做复杂业务计算。

### 2. 请求状态已抽象

已建立 `RequestState<T>`，用于统一表达：

- `idle`
- `loading`
- `success`
- `empty`
- `error`

`GoodsListViewModel` 已经使用该结构管理商品列表请求状态。首页应该继续保持 loading、empty、error、success 的分支渲染，而不是只处理成功态。

### 3. 网络层基础已搭好

已创建 `HttpClient`，包括：

- GET / POST 泛型请求
- 超时配置
- 状态码检查
- JSON 解析
- 基础错误对象
- Header 构造的 ArkTS 兼容写法

注意：ArkTS 不支持很多 TypeScript 写法，例如对象展开、索引签名、未声明对象字面量、字段索引访问。后续继续写网络层时要优先使用显式 class。

### 4. 登录态基础已搭好

已完成：

- `TokenModel`
- `TokenStore`
- `AuthService.login`
- `AuthViewModel.login`
- 登录页 `LoginPage`
- 个人中心 `ProfileTab` 和登录页联动
- `EntryAbility` 初始化 TokenStore

当前登录流程是学习用 mock 登录，后续再逐步接真实接口、Token 注入、401 处理和刷新逻辑。

### 5. ProfileTab 已优化

`ProfileTab` 已从简单占位页改成更接近真实电商个人中心的结构，并拆了多个 `@Builder`：

- 页面头部
- 用户卡片
- 订单入口
- 功能菜单
- 登录 / 退出区域

注意几个已经踩过的 ArkTS / ArkUI 点：

- `Column().gap()` 当前项目环境不可用，用 `Blank().height(...)` 处理间距。
- `@Builder` 方法返回 `void`，不要在 `this.xxxBuilder()` 后继续链式调用 `.margin()`。
- 不要使用不存在的 `sys.symbol.*` 资源名。
- `Tabs` 切换不是路由入栈，所以从首页切到个人中心后，返回键不会“回到首页”，这是正常行为。

## 最近提交记录

已完成并提交过的阶段性提交：

- `b5aea39 feat: add request state and http client foundation`
- `bf42474 feat: add auth token store and login viewmodel`
- `c0c3887 feat: wire login page into profile flow`
- `01ee8c2 feat: improve profile tab layout`

继续工作前先执行：

```bash
git status --short
```

确认是否有未提交修改。目前曾出现过 `GoodsService.ets` 只有换行类的小改动，处理前先看 diff，不要误提交无意义变更。

## 下一阶段优先级

### P0：先验证现有登录闭环

继续加功能前，先手动验证这些场景：

1. 启动 App，默认进入首页。
2. 切到个人中心，未登录时展示登录入口。
3. 点击登录入口进入 `LoginPage`。
4. 点击返回按钮可以回到个人中心。
5. 手机号和验证码为空时，登录给出错误提示。
6. 点击获取验证码后出现 60s 倒计时，倒计时期间按钮不可重复点击。
7. 输入手机号和验证码后登录成功，页面返回个人中心。
8. 个人中心展示已登录态。
9. 退出登录后清空 token，并回到未登录态。
10. 重启 App 后，`TokenStore` 能恢复登录态。

这一步的目标是确认“登录态闭环”真的稳定，不急着写刷新 Token。

### P1：优化 AuthViewModel

建议下一步先做这些小而明确的优化：

- 把发送验证码的 mock 逻辑下沉到 `AuthService.sendCode`。
- `AuthViewModel` 只负责 UI 状态、倒计时和调用 Service。
- 给倒计时补一个释放方法，例如 `disposeCountdown()`，页面销毁或离开时清理 timer。
- 手机号校验先做轻量规则：非空、数字、长度基本合理即可。
- 保留区号选择，但不要过早做完整国际号码规则。

### P2：HttpClient 注入 Token

当前 `HttpClient` 还没有真正把登录态接入请求链路。

建议实现顺序：

1. `HttpClient` 读取 `tokenStore.getAccessToken()`。
2. 如果存在 token，则请求时附加 Authorization。
3. 先只做简单 token 注入，不急着做 refresh queue。
4. 确认 HarmonyOS `http.request` 对 header 对象的真实字段要求，避免只是 ArkTS 编译通过但请求头没有真正发出去。

注意：这里很可能需要按 HarmonyOS 官方 API 调整 header 数据结构。不要为了绕过 ArkTS 类型检查写不透明的动态对象。

### P3：401 和登录失效

第一版可以简单处理：

```text
接口返回 401
  -> 清空 TokenStore
  -> 更新 AuthViewModel 登录态
  -> 跳转 LoginPage 或提示重新登录
```

第二版再做：

- RefreshToken
- 并发 401 只刷新一次
- 刷新失败统一失败并跳登录
- 等待刷新期间请求排队或重试

学习阶段建议先做第一版，能理解完整链路后再做第二版。

### P4：进入阶段 3，做商品详情 / SKU / 购物车复杂业务

登录态稳定后，进入更像真实电商客户端的业务练习：

- 商品详情页
- SKU 选择
- 库存不足
- 商品失效
- 加购数量和购物车合并
- 购物车选中、全选、失效商品、限购
- 结算前价格 / 库存二次确认

这一阶段重点不是 UI，而是业务状态组合。

## 后续学习重点

### ArkTS 约束要持续记录

已经遇到的限制包括：

- 不支持对象展开作为普通对象合并方案。
- 不支持索引签名。
- 不支持未声明类型的对象字面量。
- 不支持通过 `this['xxx']` 访问字段。
- 部分 ArkUI 属性在当前 SDK 或组件类型上不可用。

后续建议每次遇到 ArkTSCheck 错误，都记录：

- 错误原文
- 为什么 TypeScript 写法在 ArkTS 不成立
- ArkTS 推荐替代写法
- 项目里最终采用的写法

### Provider / Consumer 的学习边界

当前可以为了学习继续使用 `@Provider/@Consumer`，但要知道工程取舍：

- 适合：页面栈、主题、登录态、跨层上下文。
- 谨慎：购物车局部业务操作。
- 优先：父子组件之间用 `@Param + @Event`，数据流更清楚。

不要把“能用”误解成“大厂一定大量这么写”。真实工程更看重可维护性、可测试性和数据流可追踪。

## 保留文档

继续保留：

- `LEARNING_PLAN.md`：长期学习路线。
- `MVVM_REFACTOR_PLAN.md`：MVVM 重构方向和分层约束。
- `NEXT_STEPS.md`：当前上下文接续文档。

已清理：

- `ImprovePlan.md`：Gemini 的外部建议已吸收到学习计划中。
- `MVVM_Prompt.md`：旧提示词已被重构计划替代。
