import { useState, useRef, useEffect } from 'react'
import ChatMessage from './ChatMessage'

export default function ChatArea({ messages, loading, onSend }) {
    const [input, setInput] = useState('')
    const bottomRef = useRef(null)

    useEffect(() => {
        bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
    }, [messages, loading])

    const handleSubmit = (e) => {
        e.preventDefault()
        if (!input.trim() || loading) return
        onSend(input.trim())
        setInput('')
    }

    return (
        <div className="flex-1 flex flex-col min-h-0">
            {/* Messages — full width */}
            <div className="flex-1 overflow-y-auto">
                <div className="w-full px-8 lg:px-16 xl:px-24 py-6 space-y-6">
                    {messages.map((msg, i) => (
                        <ChatMessage key={i} message={msg} />
                    ))}

                    {loading && (
                        <div className="flex gap-3 items-start">
                            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-xs font-bold shrink-0">
                                D
                            </div>
                            <div className="pt-2">
                                <div className="flex items-center gap-2">
                                    <span className="w-2 h-2 rounded-full bg-blue-400 animate-bounce [animation-delay:0ms]"></span>
                                    <span className="w-2 h-2 rounded-full bg-purple-400 animate-bounce [animation-delay:150ms]"></span>
                                    <span className="w-2 h-2 rounded-full bg-blue-400 animate-bounce [animation-delay:300ms]"></span>
                                    <span className="ml-2 text-xs text-gray-500">Analyzing...</span>
                                </div>
                            </div>
                        </div>
                    )}

                    <div ref={bottomRef} />
                </div>
            </div>

            {/* Input — bottom pinned, full width */}
            <div className="border-t border-white/5 bg-[#0c0c14]/80 backdrop-blur-sm">
                <form onSubmit={handleSubmit} className="w-full px-8 lg:px-16 xl:px-24 py-4">
                    <div className="relative">
                        <input
                            type="text"
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            placeholder="Ask about sales, returns, promotions, inventory, or customers..."
                            className="w-full bg-[#141420] border border-white/10 rounded-xl px-5 py-4 pr-14 text-sm text-gray-100 placeholder-gray-600 focus:outline-none focus:border-blue-500/50 focus:ring-1 focus:ring-blue-500/20 transition-all"
                            disabled={loading}
                        />
                        <button
                            type="submit"
                            disabled={loading || !input.trim()}
                            className="absolute right-3 top-1/2 -translate-y-1/2 w-9 h-9 flex items-center justify-center rounded-lg bg-blue-600 hover:bg-blue-500 disabled:bg-white/5 disabled:text-gray-600 text-white text-sm font-medium transition-colors"
                        >
                            ↑
                        </button>
                    </div>
                </form>
            </div>
        </div>
    )
}
