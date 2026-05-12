import { useState, useEffect, useRef, useCallback } from 'react';
import { Send } from 'lucide-react';
import type { ChatEntry, ConnectionInfo, SSEEvent, StatusEvent } from './types';
import { fetchConnection, streamChat, reloadKnowledge } from './api';
import Sidebar from './components/Sidebar';
import WelcomeScreen from './components/WelcomeScreen';
import ChatMessage from './components/ChatMessage';
import StatusIndicator from './components/StatusIndicator';

function generateId(): string {
    return Math.random().toString(36).substring(2) + Date.now().toString(36);
}

export default function App() {
    const [sessionId] = useState(generateId);
    const [connection, setConnection] = useState<ConnectionInfo | null>(null);
    const [history, setHistory] = useState<ChatEntry[]>([]);
    const [sqlHistory, setSqlHistory] = useState<{ sql: string; rowCount: number | null }[]>([]);
    const [input, setInput] = useState('');
    const [loading, setLoading] = useState(false);
    const [status, setStatus] = useState<StatusEvent | null>(null);
    const [pendingMsg, setPendingMsg] = useState<string | null>(null);
    const [reloading, setReloading] = useState(false);
    const messagesEndRef = useRef<HTMLDivElement>(null);
    const inputRef = useRef<HTMLInputElement>(null);

    // Fetch connection info on mount
    useEffect(() => {
        fetchConnection().then(setConnection).catch(console.error);
    }, []);

    // Auto-scroll to bottom
    useEffect(() => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }, [history, status]);

    const handleSend = useCallback(async (message: string) => {
        if (!message.trim() || loading) return;

        const userMsg = message.trim();
        setInput('');
        setLoading(true);
        setStatus(null);
        setPendingMsg(userMsg);

        // Don't add to history yet — wait for result
        let currentEntry: ChatEntry = {
            userMsg,
            response: '',
            sql: null,
            rows: null,
            rowCount: null,
            chartConfig: null,
            warnings: [],
        };

        try {
            await streamChat(userMsg, sessionId, (event: SSEEvent) => {
                switch (event.type) {
                    case 'status':
                        setStatus(event as StatusEvent);
                        break;
                    case 'result':
                        setStatus(null);
                        currentEntry = {
                            ...currentEntry,
                            response: event.response,
                            sql: event.sql || null,
                            rows: event.rows || null,
                            rowCount: event.row_count,
                            chartConfig: event.chart_config || null,
                            warnings: event.warnings || [],
                        };
                        setHistory((prev) => [...prev, currentEntry]);

                        if (event.sql) {
                            setSqlHistory((prev) => [
                                ...prev,
                                { sql: event.sql, rowCount: event.row_count },
                            ]);
                        }
                        break;
                    case 'error':
                        setStatus(null);
                        currentEntry = {
                            ...currentEntry,
                            response: `Error: ${event.message}`,
                        };
                        setHistory((prev) => [...prev, currentEntry]);
                        break;
                    case 'done':
                        setStatus(null);
                        break;
                }
            });
        } catch (err) {
            setStatus(null);
            currentEntry = {
                ...currentEntry,
                response: `Error: ${err instanceof Error ? err.message : 'Unknown error'}`,
            };
            setHistory((prev) => [...prev, currentEntry]);
        } finally {
            setLoading(false);
            setPendingMsg(null);
            inputRef.current?.focus();
        }
    }, [loading, sessionId]);

    const handleKeyDown = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            handleSend(input);
        }
    };

    const handleClear = () => {
        setHistory([]);
        setSqlHistory([]);
        setStatus(null);
    };

    const handleReloadKnowledge = async () => {
        setReloading(true);
        try {
            await reloadKnowledge();
        } catch (err) {
            console.error('Failed to reload knowledge:', err);
        } finally {
            setReloading(false);
        }
    };

    return (
        <div className="app-layout">
            <Sidebar
                connection={connection}
                sqlHistory={sqlHistory}
                onClear={handleClear}
                onReloadKnowledge={handleReloadKnowledge}
                reloading={reloading}
            />

            <main className="main-content">
                {history.length === 0 && !loading ? (
                    <WelcomeScreen onSelect={handleSend} />
                ) : (
                    <div className="messages-area">
                        {history.map((entry, i) => (
                            <ChatMessage key={i} entry={entry} index={i} />
                        ))}

                        {/* Pending user message while waiting for response */}
                        {pendingMsg && (
                            <div className="chat-message user">
                                <div className="message-avatar user-avatar">🧑</div>
                                <div className="message-bubble user-bubble">
                                    <p>{pendingMsg}</p>
                                </div>
                            </div>
                        )}

                        {/* Live status during streaming */}
                        {status && (
                            <div className="chat-message assistant">
                                <div className="message-avatar assistant-avatar">⚡</div>
                                <div className="message-bubble">
                                    <StatusIndicator icon={status.icon} label={status.label} />
                                </div>
                            </div>
                        )}

                        <div ref={messagesEndRef} />
                    </div>
                )}

                {/* Chat Input */}
                <div className="chat-input-area">
                    <div className="chat-input-wrap">
                        <input
                            ref={inputRef}
                            className="chat-input"
                            type="text"
                            placeholder="Ask a question about your data..."
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            onKeyDown={handleKeyDown}
                            disabled={loading}
                        />
                        <button
                            className="send-btn"
                            onClick={() => handleSend(input)}
                            disabled={loading || !input.trim()}
                        >
                            <Send size={18} />
                        </button>
                    </div>
                </div>
            </main>
        </div>
    );
}
