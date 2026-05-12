import { AuthViewModel, authViewModel } from '../../viewmodels/Auth/AuthViewModel';

@ComponentV2
export struct ProfileTab {
  @Consumer('pageStack')
  pageStack: NavPathStack = new NavPathStack();

  @Local
  auth: AuthViewModel = authViewModel;

  aboutToAppear(): void {
    this.auth.restoreLoginState();
  }

  build() {
    // 未登录
    if (!this.auth.isLoggedIn) {
      Button('登录/注册')
        .onClick(() => {
          this.pageStack.pushPath({
            name: 'LoginPage'
          });
        })
    }
    else {
      Text('用户信息')
      Button('退出登录')
        .onClick(() => {
          this.auth.logout();
        })
    }
  }
}