import Plot from 'react-plotly.js';
import type { ChartConfig } from '../types';

const PALETTES = [
    ['#06b6d4', '#0ea5e9', '#14b8a6', '#22d3ee', '#38bdf8', '#2dd4bf', '#67e8f9', '#5eead4'],
    ['#f59e0b', '#ef4444', '#ec4899', '#f97316', '#fb923c', '#f43f5e', '#e879f9', '#fbbf24'],
    ['#8b5cf6', '#10b981', '#6366f1', '#a78bfa', '#34d399', '#818cf8', '#c084fc', '#4ade80'],
];

const LAYOUT_BASE: Partial<Plotly.Layout> = {
    paper_bgcolor: 'rgba(0,0,0,0)',
    plot_bgcolor: 'rgba(0,0,0,0)',
    font: { color: '#e2e8f0', size: 13 },
    title: { font: { color: '#f1f5f9', size: 16 } },
    legend: { bgcolor: 'rgba(0,0,0,0)', font: { color: '#cbd5e1' } },
    xaxis: { gridcolor: 'rgba(148,163,184,0.12)', zerolinecolor: 'rgba(148,163,184,0.12)' },
    yaxis: { gridcolor: 'rgba(148,163,184,0.12)', zerolinecolor: 'rgba(148,163,184,0.12)' },
    margin: { l: 50, r: 20, t: 50, b: 50 },
    autosize: true,
};

function resolveCol(columns: string[], name: string): string | undefined {
    if (columns.includes(name)) return name;
    return columns.find((c) => c.toLowerCase() === name.toLowerCase());
}

function coerceNumeric(rows: Record<string, unknown>[], cols: string[]): Record<string, unknown>[] {
    return rows.map((row) => {
        const out: Record<string, unknown> = { ...row };
        for (const col of cols) {
            const val = out[col];
            if (val != null && typeof val !== 'string') {
                out[col] = Number(val);
            }
        }
        return out;
    });
}

interface Props {
    config: ChartConfig;
    rows: Record<string, unknown>[];
    paletteIdx?: number;
}

export default function DashChart({ config, rows, paletteIdx = 0 }: Props) {
    if (!rows || rows.length === 0) return null;

    const colors = PALETTES[paletteIdx % PALETTES.length];
    const columns = Object.keys(rows[0]);

    const x = resolveCol(columns, config.x);
    const yCols = (Array.isArray(config.y) ? config.y : [config.y])
        .map((c) => resolveCol(columns, c))
        .filter(Boolean) as string[];
    const colorCol = config.color ? resolveCol(columns, config.color) : undefined;

    if (!x || yCols.length === 0) return null;

    const data = coerceNumeric(rows, yCols);
    const xVals = data.map((r) => r[x] as string);
    const orientation = config.orientation || 'v';
    const chartType = config.chart_type;
    const labels = config.labels || {};

    const traces: Plotly.Data[] = [];

    if (chartType === 'pie' || chartType === 'donut') {
        traces.push({
            type: 'pie',
            labels: xVals,
            values: data.map((r) => r[yCols[0]] as number),
            hole: chartType === 'donut' ? 0.45 : 0,
            marker: { colors },
        } as Plotly.Data);
    } else if (chartType === 'line' || chartType === 'area') {
        for (let i = 0; i < yCols.length; i++) {
            traces.push({
                type: 'scatter',
                mode: chartType === 'line' ? 'lines+markers' : 'lines',
                fill: chartType === 'area' ? 'tozeroy' : undefined,
                x: xVals,
                y: data.map((r) => r[yCols[i]] as number),
                name: labels[yCols[i]] || yCols[i],
                line: { color: colors[i % colors.length] },
                marker: { color: colors[i % colors.length] },
            } as Plotly.Data);
        }
    } else {
        // Bar variants
        const barmode = chartType === 'stacked_bar' ? 'stack' : chartType === 'grouped_bar' ? 'group' : 'group';

        if (colorCol && yCols.length === 1) {
            // Color-grouped single metric
            const groups = [...new Set(data.map((r) => r[colorCol] as string))];
            for (let i = 0; i < groups.length; i++) {
                const filtered = data.filter((r) => r[colorCol] === groups[i]);
                const xF = filtered.map((r) => r[x] as string);
                const yF = filtered.map((r) => r[yCols[0]] as number);
                traces.push({
                    type: 'bar',
                    name: groups[i],
                    x: orientation === 'h' ? yF : xF,
                    y: orientation === 'h' ? xF : yF,
                    orientation,
                    marker: { color: colors[i % colors.length] },
                } as Plotly.Data);
            }
            (LAYOUT_BASE as Record<string, unknown>).barmode = barmode;
        } else {
            for (let i = 0; i < yCols.length; i++) {
                const yVals = data.map((r) => r[yCols[i]] as number);
                traces.push({
                    type: 'bar',
                    name: labels[yCols[i]] || yCols[i],
                    x: orientation === 'h' ? yVals : xVals,
                    y: orientation === 'h' ? xVals : yVals,
                    orientation,
                    marker: { color: colors[i % colors.length] },
                } as Plotly.Data);
            }
        }

        (LAYOUT_BASE as Record<string, unknown>).barmode = barmode;
    }

    const layout: Partial<Plotly.Layout> = {
        ...LAYOUT_BASE,
        title: { text: config.title, font: { color: '#f1f5f9', size: 16 } },
    };

    // Apply axis labels
    if (labels[x]) {
        layout.xaxis = { ...layout.xaxis, title: { text: orientation === 'h' ? (labels[yCols[0]] || yCols[0]) : labels[x] } };
        layout.yaxis = { ...layout.yaxis, title: { text: orientation === 'h' ? labels[x] : (labels[yCols[0]] || '') } };
    }

    return (
        <div className="glass-chart">
            <Plot
                data={traces}
                layout={layout}
                config={{ displayModeBar: true, responsive: true }}
                useResizeHandler
                style={{ width: '100%', height: '400px' }}
            />
        </div>
    );
}
