import {
    BarChart, Bar, LineChart, Line, PieChart, Pie, Cell,
    XAxis, YAxis, CartesianGrid, Tooltip, Legend,
    ResponsiveContainer, ScatterChart, Scatter,
} from 'recharts'

const COLORS = [
    '#6ea8fe', '#f7a44c', '#ff6b6b', '#7ecbc4', '#6bc95b',
    '#ffd84d', '#c98fd1', '#ff9da7', '#c49a7c', '#d4ccc8',
]

const TOOLTIP_STYLE = {
    background: '#1a1b2e',
    border: '1px solid rgba(255,255,255,0.1)',
    borderRadius: '8px',
    color: '#e2e8f0',
    fontSize: '12px',
    padding: '8px 12px',
}

const LEGEND_STYLE = {
    color: '#a0aec0',
    fontSize: '12px',
}

function formatValue(val) {
    if (val == null) return ''
    const abs = Math.abs(val)
    const sign = val < 0 ? '-' : ''
    if (abs >= 1e12) return `${sign}$${(abs / 1e12).toFixed(1)}T`
    if (abs >= 1e9) return `${sign}$${(abs / 1e9).toFixed(1)}B`
    if (abs >= 1e6) return `${sign}$${(abs / 1e6).toFixed(1)}M`
    if (abs >= 1e3) return `${sign}$${(abs / 1e3).toFixed(0)}K`
    return val?.toLocaleString?.() ?? val
}

function CustomTooltip({ active, payload, label }) {
    if (!active || !payload?.length) return null
    return (
        <div style={TOOLTIP_STYLE}>
            <p style={{ marginBottom: 4, fontWeight: 500, color: '#f1f5f9' }}>{label}</p>
            {payload.map((entry, i) => (
                <p key={i} style={{ color: entry.color, margin: '2px 0' }}>
                    {entry.name || entry.dataKey}: {formatValue(entry.value)}
                </p>
            ))}
        </div>
    )
}

export default function DashChart({ spec }) {
    if (!spec) return null

    const {
        type = 'bar',
        title = '',
        x_label = '',
        y_label = '',
        data: rawData,
        series,
    } = spec

    // Normalize Chart.js format
    let data = rawData
    let normalizedSeries = series

    if (rawData && typeof rawData === 'object' && !Array.isArray(rawData)) {
        const labels = rawData.labels || []
        const datasets = rawData.datasets || []
        if (datasets.length > 1) {
            normalizedSeries = datasets.map((ds, i) => ({
                name: ds.label || `Series ${i + 1}`,
                data: labels.map((lbl, j) => ({ label: String(lbl), value: ds.data?.[j] || 0 })),
            }))
            data = null
        } else {
            const values = datasets[0]?.data || []
            data = labels.map((lbl, j) => ({ label: String(lbl), value: values[j] || 0 }))
        }
    }

    // Multi-series → merge into one flat array for Recharts
    let chartData = []
    let seriesKeys = []

    if (normalizedSeries && normalizedSeries.length > 0) {
        // Build merged data: { label, Series1: val, Series2: val, ... }
        const labelMap = {}
        normalizedSeries.forEach((s) => {
            seriesKeys.push(s.name)
            s.data?.forEach((d) => {
                if (!labelMap[d.label]) labelMap[d.label] = { label: d.label }
                labelMap[d.label][s.name] = d.value
            })
        })
        chartData = Object.values(labelMap)
    } else if (Array.isArray(data)) {
        chartData = data
    }

    if (chartData.length < 2) return null

    const chartType = type.toLowerCase()

    return (
        <div className="w-full">
            {title && (
                <p className="text-sm font-medium text-gray-200 mb-3 text-center">{title}</p>
            )}
            <ResponsiveContainer width="100%" height={350}>
                {chartType === 'line' ? (
                    <LineChart data={chartData} margin={{ top: 10, right: 30, bottom: 30, left: 60 }}>
                        <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.06)" />
                        <XAxis dataKey="label" stroke="#64748b" tick={{ fill: '#94a3b8', fontSize: 11 }} label={x_label ? { value: x_label, position: 'bottom', fill: '#94a3b8', fontSize: 11, offset: 15 } : undefined} />
                        <YAxis stroke="#64748b" tick={{ fill: '#94a3b8', fontSize: 11 }} tickFormatter={formatValue} label={y_label ? { value: y_label, angle: -90, position: 'insideLeft', fill: '#94a3b8', fontSize: 11 } : undefined} />
                        <Tooltip content={<CustomTooltip />} />
                        <Legend wrapperStyle={LEGEND_STYLE} />
                        {seriesKeys.length > 0
                            ? seriesKeys.map((key, i) => (
                                <Line key={key} type="monotone" dataKey={key} stroke={COLORS[i % COLORS.length]} strokeWidth={2.5} dot={{ r: 3, fill: COLORS[i % COLORS.length] }} />
                            ))
                            : <Line type="monotone" dataKey="value" stroke={COLORS[0]} strokeWidth={2.5} dot={{ r: 3, fill: COLORS[0] }} />
                        }
                    </LineChart>
                ) : chartType === 'pie' || chartType === 'donut' ? (
                    <PieChart>
                        <Pie
                            data={chartData}
                            dataKey="value"
                            nameKey="label"
                            cx="50%"
                            cy="50%"
                            outerRadius={120}
                            innerRadius={chartType === 'donut' ? 60 : 0}
                            label={({ label, percent }) => `${label} (${(percent * 100).toFixed(0)}%)`}
                            labelLine={{ stroke: '#64748b' }}
                            stroke="rgba(0,0,0,0.3)"
                        >
                            {chartData.map((_, i) => (
                                <Cell key={i} fill={COLORS[i % COLORS.length]} />
                            ))}
                        </Pie>
                        <Tooltip content={<CustomTooltip />} />
                        <Legend wrapperStyle={LEGEND_STYLE} />
                    </PieChart>
                ) : chartType === 'horizontal_bar' ? (
                    <BarChart data={chartData} layout="vertical" margin={{ top: 10, right: 30, bottom: 30, left: 100 }}>
                        <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.06)" horizontal={false} />
                        <XAxis type="number" stroke="#64748b" tick={{ fill: '#94a3b8', fontSize: 11 }} tickFormatter={formatValue} />
                        <YAxis type="category" dataKey="label" stroke="#64748b" tick={{ fill: '#94a3b8', fontSize: 11 }} width={90} />
                        <Tooltip content={<CustomTooltip />} />
                        <Bar dataKey="value" radius={[0, 6, 6, 0]}>
                            {chartData.map((_, i) => (
                                <Cell key={i} fill={COLORS[i % COLORS.length]} />
                            ))}
                        </Bar>
                    </BarChart>
                ) : chartType === 'scatter' ? (
                    <ScatterChart margin={{ top: 10, right: 30, bottom: 30, left: 60 }}>
                        <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.06)" />
                        <XAxis dataKey="x" stroke="#64748b" tick={{ fill: '#94a3b8', fontSize: 11 }} label={x_label ? { value: x_label, position: 'bottom', fill: '#94a3b8', fontSize: 11, offset: 15 } : undefined} />
                        <YAxis dataKey="y" stroke="#64748b" tick={{ fill: '#94a3b8', fontSize: 11 }} tickFormatter={formatValue} label={y_label ? { value: y_label, angle: -90, position: 'insideLeft', fill: '#94a3b8', fontSize: 11 } : undefined} />
                        <Tooltip content={<CustomTooltip />} />
                        <Scatter data={chartData} fill={COLORS[0]} />
                    </ScatterChart>
                ) : (
                    /* Default: bar chart */
                    <BarChart data={chartData} margin={{ top: 10, right: 30, bottom: 30, left: 60 }}>
                        <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.06)" vertical={false} />
                        <XAxis dataKey="label" stroke="#64748b" tick={{ fill: '#94a3b8', fontSize: 11 }} label={x_label ? { value: x_label, position: 'bottom', fill: '#94a3b8', fontSize: 11, offset: 15 } : undefined} />
                        <YAxis stroke="#64748b" tick={{ fill: '#94a3b8', fontSize: 11 }} tickFormatter={formatValue} label={y_label ? { value: y_label, angle: -90, position: 'insideLeft', fill: '#94a3b8', fontSize: 11 } : undefined} />
                        <Tooltip content={<CustomTooltip />} cursor={{ fill: 'rgba(255,255,255,0.03)' }} />
                        {seriesKeys.length > 0 ? (
                            <>
                                <Legend wrapperStyle={LEGEND_STYLE} />
                                {seriesKeys.map((key, i) => (
                                    <Bar key={key} dataKey={key} fill={COLORS[i % COLORS.length]} radius={[6, 6, 0, 0]} />
                                ))}
                            </>
                        ) : (
                            <Bar dataKey="value" radius={[6, 6, 0, 0]}>
                                {chartData.map((_, i) => (
                                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                                ))}
                            </Bar>
                        )}
                    </BarChart>
                )}
            </ResponsiveContainer>
        </div>
    )
}
