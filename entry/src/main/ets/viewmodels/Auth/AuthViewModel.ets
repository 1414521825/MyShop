import { TokenModel } from "../../models/Auth/TokenModel";
import { authService } from "../../services/AuthService";
import { tokenStore } from "../../services/TokenStore";

@ObservedV2
export class AuthViewModel {
  @Trace isLoggedIn: boolean = false;
  @Trace isLoggingIn: boolean = false;
  @Trace isSendingCode: boolean = false;
  @Trace codeCountdown: number = 0;
  @Trace errorMessage: string = '';
  private countdownTimer: number = -1;

  restoreLoginState(): void {
    this.isLoggedIn = tokenStore.isLoggedIn();
    this.errorMessage = '';
  }

  async login(phone: string, code: string): Promise<void> {
    if (phone.length === 0) {
      this.errorMessage = '请输入手机号';
      return;
    }

    if (code.length === 0) {
      this.errorMessage = '请输入验证码';
      return;
    }

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

  async sendCode(phone: string): Promise<void> {
    if (this.codeCountdown > 0 || this.isSendingCode) {
      return;
    }

    if (phone.length === 0) {
      this.errorMessage = '请输入手机号';
      return;
    }

    this.isSendingCode = true;
    this.errorMessage = '';

    try {
      await authService.sendCode(phone);
      this.startCodeCountdown();
    } catch (err) {
      this.errorMessage = '验证码发送失败';
    } finally {
      this.isSendingCode = false;
    }
  }

  logout(): void {
    tokenStore.clearToken();
    this.isLoggedIn = false;
    this.errorMessage = '';
  }

  disposeCountdown(): void {
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = -1;
    }

    this.codeCountdown = 0;
  }

  private startCodeCountdown(): void {
    this.codeCountdown = 60;

    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer);
    }

    this.countdownTimer = setInterval(() => {
      if (this.codeCountdown <= 1) {
        this.codeCountdown = 0;
        clearInterval(this.countdownTimer);
        this.countdownTimer = -1;
        return;
      }

      this.codeCountdown--;
    }, 1000);
  }
}

export const authViewModel = new AuthViewModel();
