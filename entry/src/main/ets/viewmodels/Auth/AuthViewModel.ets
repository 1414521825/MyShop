import { TokenModel } from "../../models/Auth/TokenModel";
import { authService } from "../../services/AuthService";
import { tokenStore } from "../../services/TokenStore";

@ObservedV2
export class AuthViewModel {
  @Trace isLoggedIn: boolean = false;
  @Trace isLoggingIn: boolean = false;
  @Trace errorMessage: string = '';

  restoreLoginState(): void {
    this.isLoggedIn = tokenStore.isLoggedIn();
    this.errorMessage = '';
  }

  async login(phone: string, code: string): Promise<void> {
    this.isLoggingIn = true;
    this.errorMessage = '';

    try {
      const token: TokenModel = await authService.login(phone, code);
      tokenStore.saveToken(token);
      this.isLoggedIn = true;
    } catch (err) {
      this.isLoggedIn = false;
      this.errorMessage = '登录失败';
    } finally {
      this.isLoggingIn = false;
    }
  }

  logout(): void {
    tokenStore.clearToken();
    this.isLoggedIn = false;
    this.errorMessage = '';
  }
}

export const authViewModel = new AuthViewModel();
