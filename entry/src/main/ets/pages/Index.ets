import { HomeTab } from "../views/Tabs/HomeTab";
import { ProfileTab } from "../views/Tabs/ProfileTab";
import { ShopCartTab } from "../views/Tabs/ShopCartTab";
import { LoginPage } from "./LoginPage";

@Entry
@ComponentV2
struct Index {
  @Provider('pageStack')
  pageStack: NavPathStack = new NavPathStack();
  @Builder
  PagesMap(name: string) {
    if (name === 'LoginPage') {
      LoginPage();
    }
  }

  build() {
    Navigation(this.pageStack) {
      Tabs() {
        TabContent() {
          HomeTab()
            .backgroundColor('#EBEBEB')
        }
          .tabBar("首页")
        TabContent()
          .tabBar("分类")
        TabContent()
          .tabBar("消息")
        TabContent() {
          ShopCartTab()
        }
          .tabBar("购物车")
        TabContent() {
          ProfileTab()
        }
          .tabBar("个人中心")
      }
      .barPosition(BarPosition.End)
    }
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
    .navDestination(this.PagesMap)
  }
}
