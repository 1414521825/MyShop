import { TokenModel } from "../models/Auth/TokenModel";

export class AuthService {
  async login(phone: string, code: string): Promise<TokenModel> {
    if (phone.length === 0 || code.length === 0) {
      throw new Error('手机号和验证码不能为空');
    }

    // Mock 登录：真实接口接入后，这里改为 httpClient.post<TokenModel>()。
    return new TokenModel(
      'mock_access_token',
      'mock_refresh_token',
      Date.now() + 2 * 60 * 60 * 1000
    );
  }
}

export const authService = new AuthService();
