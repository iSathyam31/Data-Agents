import type { ChatEntry } from '../types';
import DashChart from './DashChart';
import Expandable from './Expandable';

interface Props {
    entry: ChatEntry;
    index: number;
}

export default function ChatMessage({ entry, index }: Props) {
    return (
        <>
            {/* User message */}
            <div className="chat-message user">
                <div className="message-avatar user-avatar">🧑</div>
                <div className="message-bubble user-bubble">
                    <p>{entry.userMsg}</p>
                </div>
            </div>

            {/* Assistant message */}
            <div className="chat-message assistant">
                <div className="message-avatar assistant-avatar">⚡</div>
                <div className="message-bubble">
                    <p>{entry.response}</p>

                    {/* Chart */}
                    {entry.chartConfig && entry.rows && entry.rows.length > 0 && (
                        <DashChart config={entry.chartConfig} rows={entry.rows} paletteIdx={index} />
                    )}

                    {/* SQL Query */}
                    {entry.sql && (
                        <Expandable icon="🔍" title="SQL Query">
                            <pre className="sql-code">{entry.sql}</pre>
                        </Expandable>
                    )}

                    {/* Raw Results */}
                    {entry.rows && entry.rows.length > 0 && (
                        <Expandable icon="📋" title={`Raw Results (${entry.rowCount} rows)`}>
                            <div className="data-table-wrap">
                                <table className="data-table">
                                    <thead>
                                        <tr>
                                            {Object.keys(entry.rows[0]).map((col) => (
                                                <th key={col}>{col}</th>
                                            ))}
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {entry.rows.map((row, i) => (
                                            <tr key={i}>
                                                {Object.values(row).map((val, j) => (
                                                    <td key={j}>{formatValue(val)}</td>
                                                ))}
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </Expandable>
                    )}

                    {/* Warnings */}
                    {entry.warnings.length > 0 && (
                        <Expandable icon="⚠️" title="Warnings">
                            {entry.warnings.map((w, i) => (
                                <div key={i} className="warning-badge">⚠️ {w}</div>
                            ))}
                        </Expandable>
                    )}
                </div>
            </div>
        </>
    );
}

function formatValue(val: unknown): string {
    if (val === null || val === undefined) return '—';
    if (typeof val === 'number') {
        return val.toLocaleString();
    }
    return String(val);
}
