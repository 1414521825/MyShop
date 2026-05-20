import http from "@ohos.net.http";
import { tokenStore } from "./TokenStore";

export class HttpRequestHeaders {
  contentType: string = 'application/json';
  authorization: string = '';
  traceId: string = '';

  constructor(contentType: string = 'application/json', authorization: string = '', traceId: string = '') {
    this.contentType = contentType;
    this.authorization = authorization;
    this.traceId = traceId;
  }
}

class HttpHeaderObject {
  contentType: string = 'application/json';
  authorization: string = '';
  traceId: string = '';

  constructor(contentType: string, authorization: string, traceId: string) {
    this.contentType = contentType;
    this.authorization = authorization;
    this.traceId = traceId;
  }
}

export class HttpError extends Error {
  statusCode: number;
  rawResult: string;

  constructor(message: string, statusCode: number = -1, rawResult: string = '') {
    super(message);
    this.statusCode = statusCode;
    this.rawResult = rawResult;
  }
}

export class HttpClient {
  private baseUrl: string = ''; // Mock阶段为空

  async get<T>(path: string, headers?: HttpRequestHeaders): Promise<T> {
    return this.request<T>(path, http.RequestMethod.GET, undefined, headers);
  }

  async post<T>(path: string, body: Object, headers?: HttpRequestHeaders): Promise<T> {
    return this.request<T>(path, http.RequestMethod.POST, body, headers);
  }

  private async request<T>(
    path: string,
    method: http.RequestMethod,
    body?: Object,
    headers?: HttpRequestHeaders
  ): Promise<T> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(
        this.baseUrl + path,
        {
          method: method,
          extraData: body === undefined ? undefined : JSON.stringify(body),
          header: this.buildHeaders(headers),
          connectTimeout: 10000,
          readTimeout: 10000
        }
      );

      const statusCode = response.responseCode;
      const rawResult = response.result as string;

      if (statusCode === 401) {
        tokenStore.clearToken();
        throw new HttpError('登录已失效，请重新登录', statusCode, rawResult);
      }

      if (statusCode < 200 || statusCode >= 300) {
        throw new HttpError('HTTP 请求失败', statusCode, rawResult);
      }

      return this.parseJson<T>(rawResult, statusCode);
    } catch (err) {
      if (err instanceof HttpError) {
        throw err;
      }

      throw new HttpError('网络请求异常', -1, JSON.stringify(err));
    } finally {
      httpRequest.destroy();
    }
  }

  private parseJson<T>(rawResult: string, statusCode: number): T {
    try {
      return JSON.parse(rawResult) as T;
    } catch (err) {
      throw new HttpError('响应数据解析失败', statusCode, rawResult);
    }
  }

  private buildHeaders(headers?: HttpRequestHeaders): HttpHeaderObject {
    let contentType: string = 'application/json';
    let authorization: string = '';
    let traceId: string = '';

    if (headers !== undefined) {
      contentType = headers.contentType;
      authorization = headers.authorization;
      traceId = headers.traceId;
    }

    if (authorization.length === 0) {
      const token: string = tokenStore.getAccessToken();
      if (token.length > 0) {
        // Bearer 代表认证类型
        authorization = `Bearer ${token}`;
      }
    }
    console.info(`[HttpClient] hasAuthorization=${authorization.length > 0}`);

    return new HttpHeaderObject(contentType, authorization, traceId);
  }
}

export const httpClient = new HttpClient();
