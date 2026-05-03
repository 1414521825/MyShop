@ComponentV2
export struct StatisticsView {
  @Require @Param
  buyCount: number;
  @Require @Param
  totalAmount: number = 0;
  @Require @Param
  isAllChecked: boolean = false;
  @Event
  allCheckedChange: (isAllChecked: boolean) => void = () => {
  };

  build() {
    Row() {
      Row() {
        Checkbox()
          .select(this.isAllChecked)
          .width(20).height(20)
          .margin({
            left: 2,
            top: 2,
            right: 5,
            bottom: 2
          })
          .onChange((value: boolean) => {
            this.allCheckedChange(value);
          })

        Text('全选')
          .fontSize(16)
          .fontWeight(400)
          .onClick(() => {
            this.allCheckedChange(!this.isAllChecked);
          })
      }
      .width(80)
      .height(24)

      Button(`总计 ￥${this.totalAmount}   结算(${this.buyCount})`)
        .width(240)
        .height(40)
        .fontSize(18)
        .fontWeight(500)
        .fontColor(Color.White)
        .backgroundColor('rgba(10,89,247,1)')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor('rgba(241,243,245,0.8)')
    .backdropBlur(80)
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
  }
}
