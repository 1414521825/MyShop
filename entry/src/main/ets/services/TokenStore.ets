import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { TokenModel } from '../models/Auth/TokenModel';

const STORE_NAME: string = 'auth_token_store';
const KEY_ACCESS_TOKEN: string = 'access_token';
const KEY_REFRESH_TOKEN: string = 'refresh_token';
const KEY_EXPIRES_AT: string = 'expires_at';

export class TokenStore {
  private store?: preferences.Preferences;

  init(context: common.Context): void {
    if (this.store !== undefined) {
      return;
    }

    const options: preferences.Options = {
      name: STORE_NAME
    };
    this.store = preferences.getPreferencesSync(context, options);
  }

  saveToken(token: TokenModel): void {
    const store = this.requireStore();

    store.putSync(KEY_ACCESS_TOKEN, token.accessToken);
    store.putSync(KEY_REFRESH_TOKEN, token.refreshToken);
    store.putSync(KEY_EXPIRES_AT, token.expiresAt);
    store.flushSync();
  }

  getToken(): TokenModel | null {
    const store = this.requireStore();
    const accessToken = store.getSync(KEY_ACCESS_TOKEN, '') as string;
    const refreshToken = store.getSync(KEY_REFRESH_TOKEN, '') as string;
    const expiresAt = store.getSync(KEY_EXPIRES_AT, 0) as number;

    if (accessToken.length === 0 || refreshToken.length === 0) {
      return null;
    }

    return new TokenModel(accessToken, refreshToken, expiresAt);
  }

  getAccessToken(): string {
    const token = this.getToken();
    if (token === null) {
      return '';
    }

    return token.accessToken;
  }

  getRefreshToken(): string {
    const token = this.getToken();
    if (token === null) {
      return '';
    }

    return token.refreshToken;
  }

  hasToken(): boolean {
    return this.getToken() !== null;
  }

  isLoggedIn(): boolean {
    const token = this.getToken();
    if (token === null) {
      return false;
    }

    return !token.isExpired();
  }

  clearToken(): void {
    const store = this.requireStore();

    store.deleteSync(KEY_ACCESS_TOKEN);
    store.deleteSync(KEY_REFRESH_TOKEN);
    store.deleteSync(KEY_EXPIRES_AT);
    store.flushSync();
  }

  private requireStore(): preferences.Preferences {
    if (this.store === undefined) {
      throw new Error('TokenStore 未初始化，请先在 EntryAbility 中调用 tokenStore.init(context)');
    }

    return this.store;
  }
}

export const tokenStore = new TokenStore();
