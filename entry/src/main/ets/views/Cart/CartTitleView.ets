@ComponentV2
export struct CartTitleView {
  @Event
  deleteCart: () => void = () => {
  };

  build() {
    Row() {
      Row() {
        Text('购物车')
          .fontSize(26)
          .fontWeight(700)

        Button() {
          SymbolGlyph($r('sys.symbol.trash'))
            .fontSize(24)
            .fontColor([Color.Black]) // 字体颜色
            .onClick(() => this.deleteCart());
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor('rgba(0,0,0,0.05)')
      }
      .width('100%')
      .height(56)
      // justifyContent用于设置子组件在垂直方向上的对齐格式
      // FlexAlign.SpaceBetween相邻元素之间距离相同。第一个元素与行首对齐，最后一个元素与行尾对齐
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor('rgba(241,243,245,0.8)')
    .backdropBlur(80) // 背景模糊效果,越大越模糊
    .padding({
      // 内边距
      top: 36,
      left: 16,
      right: 16,
      bottom: 14
    })
  }
}