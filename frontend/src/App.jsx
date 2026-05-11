import { useState } from 'react'
import ChatArea from './components/ChatArea'
import Sidebar from './components/Sidebar'
import WelcomeScreen from './components/WelcomeScreen'

export default function App() {
    const [messages, setMessages] = useState([])
    const [loading, setLoading] = useState(false)
    const [sessionId] = useState('default')

    const sendMessage = async (text) => {
        const userMsg = { role: 'user', content: text }
        setMessages((prev) => [...prev, userMsg])
        setLoading(true)

        try {
            const res = await fetch('/api/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message: text, session_id: sessionId }),
            })

            const responseText = await res.text()
            if (!responseText) {
                throw new Error('Empty response from server — the agent may have timed out. Try again.')
            }

            let data
            try {
                data = JSON.parse(responseText)
            } catch {
                throw new Error('Invalid response from server. Please try again.')
            }

            if (!res.ok) {
                throw new Error(data.detail || `Request failed (${res.status})`)
            }

            const assistantMsg = {
                role: 'assistant',
                content: data.message,
                chart: data.chart || null,
                sql: data.sql || null,
            }
            setMessages((prev) => [...prev, assistantMsg])
        } catch (e) {
            setMessages((prev) => [
                ...prev,
                { role: 'assistant', content: `⚠️ Error: ${e.message}` },
            ])
        } finally {
            setLoading(false)
        }
    }

    const clearChat = async () => {
        try {
            await fetch(`/api/chat/clear?session_id=${sessionId}`, { method: 'POST' })
        } catch (_) { }
        setMessages([])
    }

    return (
        <div className="h-screen flex bg-[#0a0a0f]">
            {/* Sidebar */}
            <Sidebar onClear={clearChat} onSampleClick={sendMessage} />

            {/* Main content area */}
            <div className="flex-1 flex flex-col min-w-0">
                {messages.length === 0 ? (
                    <WelcomeScreen onSend={sendMessage} />
                ) : (
                    <ChatArea
                        messages={messages}
                        loading={loading}
                        onSend={sendMessage}
                    />
                )}
            </div>
        </div>
    )
}
