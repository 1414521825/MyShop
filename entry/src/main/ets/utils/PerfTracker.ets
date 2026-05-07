import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0001;
const TAG = 'PerfTracker';

export class PerfTracker {
  private marks: Map<string, number> = new Map();

  start(label: string): void {
    this.marks.set(label, Date.now());
    hilog.info(DOMAIN, TAG, `[start] ${label}`);
  }

  end(label: string): void {
    const start = this.marks.get(label);
    if (start !== undefined) {
      const cost = Date.now() - start;
      hilog.info(DOMAIN, TAG, `[end] ${label}: ${cost}ms`);
      this.marks.delete(label);
    }
  }

  mark(label: string): void {
    this.marks.set(label, Date.now());
  }

  measure(from: string, to: string): void {
    const start = this.marks.get(from);
    const end = this.marks.get(to);
    if (start !== undefined && end !== undefined) {
      hilog.info(DOMAIN, TAG, `[${from} → ${to}]: ${end - start}ms`);
    }
  }

  clear(): void {
    this.marks.clear();
  }
}

export const perfTracker = new PerfTracker();
