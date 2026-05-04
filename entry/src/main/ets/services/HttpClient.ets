import http from "@ohos.net.http";

export class HttpClient {
  private baseUrl: string = ''; // Mocl阶段为空

  async get(path: string): Promise<Object> {
    let httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        this.baseUrl + path,
        {
          method: http.RequestMethod.GET
        }
      );
      return JSON.parse(response.result as string);
    } finally {
      httpRequest.destroy();
    }
  }

  async post(path: string, body: Object): Promise<Object> {
    let httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        this.baseUrl + path,
        {
          method: http.RequestMethod.POST,
          extraData: body,
          header: {'Content-Type': 'application/json'}
        }
      );
      return JSON.parse(response.result as string);
    } finally {
      httpRequest.destroy();
    }
  }
}

export const httpClient = new HttpClient();