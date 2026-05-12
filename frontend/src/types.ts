export interface ChatEntry {
    userMsg: string;
    response: string;
    sql: string | null;
    rows: Record<string, unknown>[] | null;
    rowCount: number | null;
    chartConfig: ChartConfig | null;
    warnings: string[];
}

export interface ChartConfig {
    chart_type: 'bar' | 'grouped_bar' | 'stacked_bar' | 'line' | 'area' | 'pie' | 'donut';
    title: string;
    x: string;
    y: string[];
    color?: string;
    orientation?: 'v' | 'h';
    labels?: Record<string, string>;
}

export interface StatusEvent {
    type: 'status';
    node: string;
    icon: string;
    label: string;
}

export interface ResultEvent {
    type: 'result';
    response: string;
    sql: string;
    rows: Record<string, unknown>[] | null;
    row_count: number | null;
    chart_config: ChartConfig | null;
    warnings: string[];
}

export interface ErrorEvent {
    type: 'error';
    message: string;
}

export interface DoneEvent {
    type: 'done';
}

export type SSEEvent = StatusEvent | ResultEvent | ErrorEvent | DoneEvent;

export interface ConnectionInfo {
    database: string;
    schema_name: string;
    warehouse: string;
    role: string;
}
