import { AuthViewModel, authViewModel } from '../viewmodels/Auth/AuthViewModel';

class PhoneRegionOption {
  label: string;
  code: string;

  constructor(label: string, code: string) {
    this.label = label;
    this.code = code;
  }
}

@ComponentV2
export struct LoginPage {
  @Local phone: string = '';
  @Local code: string = '';
  @Local selectedRegionCode: string = '+86';
  @Local showRegionPanel: boolean = false;
  @Local auth: AuthViewModel = authViewModel;
  private regionOptions: PhoneRegionOption[] = [
    new PhoneRegionOption('中国大陆', '+86'),
    new PhoneRegionOption('中国香港', '+852'),
    new PhoneRegionOption('中国澳门', '+853'),
    new PhoneRegionOption('中国台湾', '+886')
  ];

  @Consumer('pageStack')
  pageStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.auth.restoreLoginState();
  }

  aboutToDisappear(): void {
    this.auth.disposeCountdown();
  }

  @Builder
  DividerLine() {
    Divider()
      .strokeWidth(0.5)
      .color('#E5E5E5')
  }

  @Builder
  PhoneRow() {
    Row() {
      Row() {
        Text(this.selectedRegionCode)
          .fontSize(16)
          .fontColor('#111111')
        Text('>')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ left: 4 })
      }
      .height(52)
      .padding({ right: 12 })
      .onClick(() => {
        this.showRegionPanel = true;
      })

      TextInput({ placeholder: '手机号' })
        .layoutWeight(1)
        .height(52)
        .backgroundColor(Color.Transparent)
        .type(InputType.PhoneNumber)
        .onChange((value: string) => {
          this.phone = value;
        })
    }
    .width('100%')
    .height(52)
  }

  @Builder
  CodeRow() {
    Row() {
      TextInput({ placeholder: '验证码' })
        .layoutWeight(1)
        .height(52)
        .backgroundColor(Color.Transparent)
        .type(InputType.Number)
        .onChange((value: string) => {
          this.code = value;
        })

      Button(this.codeButtonText())
        .height(34)
        .fontSize(13)
        .fontColor(this.auth.codeCountdown > 0 ? '#999999' : '#E02E24')
        .backgroundColor(Color.Transparent)
        .enabled(this.auth.codeCountdown === 0 && !this.auth.isSendingCode)
        .onClick(() => {
          this.auth.sendCode(this.phone);
        })
    }
    .width('100%')
    .height(52)
  }

  @Builder
  RegionPanel() {
    Column() {
      Blank()
        .layoutWeight(1)
        .onClick(() => {
          this.showRegionPanel = false;
        })

      Column() {
        Text('选择国家或地区')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 18, bottom: 8 })

        ForEach(this.regionOptions, (item: PhoneRegionOption) => {
          Row() {
            Text(item.label)
              .fontSize(16)
              .fontColor('#111111')
            Blank()
            Text(item.code)
              .fontSize(16)
              .fontColor('#666666')
          }
          .width('100%')
          .height(48)
          .padding({ left: 20, right: 20 })
          .onClick(() => {
            this.selectedRegionCode = item.code;
            this.showRegionPanel = false;
          })
        }, (item: PhoneRegionOption) => item.code)

        Button('取消')
          .width('100%')
          .height(44)
          .fontColor('#111111')
          .backgroundColor('#F5F5F5')
          .margin({ top: 8, bottom: 12 })
          .onClick(() => {
            this.showRegionPanel = false;
          })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
  }

  private codeButtonText(): string {
    if (this.auth.codeCountdown > 0) {
      return `${this.auth.codeCountdown}s`;
    }

    if (this.auth.isSendingCode) {
      return '发送中';
    }

    return '获取验证码';
  }

  private async handleLogin(): Promise<void> {
    await this.auth.login(this.phone, this.code);

    if (this.auth.isLoggedIn) {
      this.pageStack.pop();
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Text('手机号登录')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111111')
            .width('100%')
            .margin({ top: 72, bottom: 32 })

          Column() {
            this.PhoneRow()
            this.DividerLine()
            this.CodeRow()
            this.DividerLine()
          }
          .width('100%')

          if (this.auth.errorMessage.length > 0) {
            Text(this.auth.errorMessage)
              .fontSize(13)
              .fontColor('#E02E24')
              .width('100%')
              .margin({ top: 12 })
          }

          Button(this.auth.isLoggingIn ? '登录中...' : '登录')
            .width('100%')
            .height(46)
            .fontSize(17)
            .fontColor(Color.White)
            .backgroundColor('#E02E24')
            .borderRadius(23)
            .enabled(!this.auth.isLoggingIn)
            .margin({ top: 28 })
            .onClick(() => {
              this.handleLogin();
            })

          if (this.auth.isLoggedIn) {
            Text('已登录')
              .fontSize(13)
              .fontColor('#2E7D32')
              .margin({ top: 16 })
          }
        }
        .width('100%')
        .height('100%')
        .padding({ left: 24, right: 24 })
        .backgroundColor(Color.White)

        if (this.showRegionPanel) {
          this.RegionPanel()
        }
      }
      .width('100%')
      .height('100%')
    }
    .title('登录')
    .hideTitleBar(true)
  }
}
