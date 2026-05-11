export class TokenModel {
  accessToken: string;
  refreshToken: string;
  expiresAt: number;

  constructor(accessToken: string, refreshToken: string, expiresAt: number) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.expiresAt = expiresAt;
  }

  isExpired(now: number = Date.now()): boolean {
    return this.expiresAt <= now;
  }
}
