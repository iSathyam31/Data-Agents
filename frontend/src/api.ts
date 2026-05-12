import type { ConnectionInfo, SSEEvent } from './types';

const BASE = '/api';

export async function fetchConnection(): Promise<ConnectionInfo> {
    const res = await fetch(`${BASE}/connection`);
    if (!res.ok) throw new Error('Failed to fetch connection info');
    return res.json();
}

export async function streamChat(
    message: string,
    sessionId: string,
    onEvent: (event: SSEEvent) => void,
): Promise<void> {
    const res = await fetch(`${BASE}/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message, session_id: sessionId }),
    });

    if (!res.ok) throw new Error(`Chat request failed: ${res.status}`);

    const reader = res.body?.getReader();
    if (!reader) throw new Error('No response body');

    const decoder = new TextDecoder();
    let buffer = '';

    while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (const line of lines) {
            if (line.startsWith('data: ')) {
                try {
                    const event: SSEEvent = JSON.parse(line.slice(6));
                    onEvent(event);
                } catch {
                    // skip malformed JSON
                }
            }
        }
    }
}

export async function reloadKnowledge(): Promise<void> {
    const res = await fetch(`${BASE}/reload-knowledge`, { method: 'POST' });
    if (!res.ok) throw new Error('Failed to reload knowledge');
}
