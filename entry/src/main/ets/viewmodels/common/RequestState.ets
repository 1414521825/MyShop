export type RequestStatus = 'idle' | 'loading' | 'success' | 'empty' | 'error';

@ObservedV2
export class RequestState<T> {
  @Trace status: RequestStatus = 'idle';
  @Trace data?: T;
  @Trace errorMessage: string = '';

  loading(): void {
    this.status = 'loading';
    this.errorMessage = '';
  }

  success(data: T): void {
    this.status = 'success';
    this.data = data;
    this.errorMessage = '';
  }

  empty(): void {
    this.status = 'empty';
    this.data = undefined;
    this.errorMessage = '';
  }

  error(message: string): void {
    this.status = 'error';
    this.errorMessage = message;
  }
}