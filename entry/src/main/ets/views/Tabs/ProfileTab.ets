import { AuthViewModel, authViewModel } from '../../viewmodels/Auth/AuthViewModel';

class ProfileMenuItem {
  title: string;
  desc: string;
  iconText: string;

  constructor(title: string, desc: string, iconText: string) {
    this.title = title;
    this.desc = desc;
    this.iconText = iconText;
  }
}

@ComponentV2
export struct ProfileTab {
  @Consumer('pageStack')
  pageStack: NavPathStack = new NavPathStack();
  @Local auth: AuthViewModel = authViewModel;
  private menuItems: ProfileMenuItem[] = [
    new ProfileMenuItem('收货地址', '管理常用地址', '址'),
    new ProfileMenuItem('优惠券', '查看可用优惠', '券'),
    new ProfileMenuItem('客服与帮助', '订单问题与反馈', '服'),
    new ProfileMenuItem('设置', '账号与隐私设置', '设')
  ];

  aboutToAppear(): void {
    this.auth.restoreLoginState();
  }

  @Builder
  PageHeader() {
    Row() {
      Text('个人中心')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111111')
      Blank()
      Button() {
        Text('铃')
          .fontSize(15)
          .fontColor('#333333')
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor('#F2F3F5')
    }
    .width('100%')
    .height(52)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  UserCard() {
    Row() {
      Stack() {
        Circle()
          .width(64)
          .height(64)
          .fill(this.auth.isLoggedIn ? '#E02E24' : '#D9DDE3')
        Text(this.auth.isLoggedIn ? '我' : '未')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }

      Column() {
        if (this.auth.isLoggedIn) {
          Text('拼单用户')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111111')
          Text('账号已登录，购物车和订单状态会自动同步')
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 6 })
        } else {
          Text('登录后体验更多服务')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111111')
          Text('同步购物车、查看订单、参与拼团')
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 6 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })

      if (!this.auth.isLoggedIn) {
        Button('登录/注册')
          .height(36)
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#E02E24')
          .borderRadius(18)
          .onClick(() => {
            this.openLoginPage();
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder
  OrderPanel() {
    Column() {
      Row() {
        Text('我的订单')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111111')
        Blank()
        Text('全部订单 >')
          .fontSize(13)
          .fontColor('#999999')
      }
      .width('100%')
      .height(32)

      Row() {
        this.OrderShortcut('待付款', '付')
        this.OrderShortcut('待发货', '发')
        this.OrderShortcut('待收货', '收')
        this.OrderShortcut('退款/售后', '退')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder
  OrderShortcut(title: string, iconText: string) {
    Column() {
      Stack() {
        Circle()
          .width(34)
          .height(34)
          .fill('#FFF1F0')
        Text(iconText)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E02E24')
      }
      Text(title)
        .fontSize(12)
        .fontColor('#333333')
        .margin({ top: 6 })
    }
    .width(72)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  MenuPanel() {
    Column() {
      ForEach(this.menuItems, (item: ProfileMenuItem) => {
        this.MenuRow(item)
      }, (item: ProfileMenuItem) => item.title)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
  }

  @Builder
  MenuRow(item: ProfileMenuItem) {
    Row() {
      Stack() {
        Circle()
          .width(32)
          .height(32)
          .fill('#FFF1F0')
        Text(item.iconText)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E02E24')
      }
        .margin({ right: 12 })

      Column() {
        Text(item.title)
          .fontSize(15)
          .fontColor('#111111')
        Text(item.desc)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 3 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('>')
        .fontSize(16)
        .fontColor('#C0C0C0')
    }
    .width('100%')
    .height(58)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  LogoutButton() {
    if (this.auth.isLoggedIn) {
      Button('退出登录')
        .width('100%')
        .height(44)
        .fontSize(15)
        .fontColor('#E02E24')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .onClick(() => {
          this.auth.logout();
        })
    }
  }

  private openLoginPage(): void {
    this.pageStack.pushPath({
      name: 'LoginPage'
    });
  }

  build() {
    Scroll() {
      Column() {
        this.PageHeader()
        Blank()
          .height(12)
        this.UserCard()
        Blank()
          .height(12)
        this.OrderPanel()
        Blank()
          .height(12)
        this.MenuPanel()
        Blank()
          .height(12)
        this.LogoutButton()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 48, bottom: 24 })
      .backgroundColor('#F5F6F8')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F8')
  }
}
