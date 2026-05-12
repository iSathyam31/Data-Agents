import type { ConnectionInfo } from '../types';
import { Trash2, BookOpen } from 'lucide-react';

interface SqlEntry {
    sql: string;
    rowCount: number | null;
}

interface Props {
    connection: ConnectionInfo | null;
    sqlHistory: SqlEntry[];
    onClear: () => void;
    onReloadKnowledge: () => void;
    reloading: boolean;
}

export default function Sidebar({ connection, sqlHistory, onClear, onReloadKnowledge, reloading }: Props) {
    return (
        <aside className="sidebar">
            <div className="sidebar-brand">
                <h1>⚡ Dash</h1>
            </div>
            <p className="sidebar-caption">Self-learning data agent for Snowflake</p>

            <hr className="sidebar-divider" />

            <h3 className="sidebar-section-title">Connection</h3>
            {connection ? (
                <>
                    <div className="conn-item">
                        <span className="label">Database:</span>
                        <span className="value">{connection.database}</span>
                    </div>
                    <div className="conn-item">
                        <span className="label">Schema:</span>
                        <span className="value">{connection.schema_name}</span>
                    </div>
                    <div className="conn-item">
                        <span className="label">Warehouse:</span>
                        <span className="value">{connection.warehouse}</span>
                    </div>
                    <div className="conn-item">
                        <span className="label">Role:</span>
                        <span className="value">{connection.role}</span>
                    </div>
                </>
            ) : (
                <p style={{ color: 'var(--text-muted)', fontSize: '0.82rem' }}>Loading...</p>
            )}

            <hr className="sidebar-divider" />

            <h3 className="sidebar-section-title">SQL History</h3>
            {sqlHistory.length === 0 ? (
                <p style={{ color: 'var(--text-muted)', fontSize: '0.82rem' }}>No queries yet.</p>
            ) : (
                <div style={{ maxHeight: '220px', overflowY: 'auto' }}>
                    {[...sqlHistory].reverse().slice(0, 10).map((entry, i) => (
                        <div key={i} className="sql-history-item">
                            <div className="title">Query {sqlHistory.length - i}</div>
                            <div className="meta">
                                {entry.rowCount != null ? `${entry.rowCount} rows` : '—'}
                            </div>
                        </div>
                    ))}
                </div>
            )}

            <hr className="sidebar-divider" />

            <button className="sidebar-btn" onClick={onClear}>
                <Trash2 size={14} style={{ marginRight: 8, verticalAlign: 'middle' }} />
                Clear Chat
            </button>

            <hr className="sidebar-divider" />

            <h3 className="sidebar-section-title">Knowledge Base</h3>
            <button className="sidebar-btn" onClick={onReloadKnowledge} disabled={reloading}>
                <BookOpen size={14} style={{ marginRight: 8, verticalAlign: 'middle' }} />
                {reloading ? 'Reloading...' : 'Reload Knowledge'}
            </button>
        </aside>
    );
}
