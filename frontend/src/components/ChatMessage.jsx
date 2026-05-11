import { useState } from 'react'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import DashChart from './DashChart'

export default function ChatMessage({ message }) {
    const { role, content, chart, sql } = message
    const [showSql, setShowSql] = useState(false)

    const isUser = role === 'user'

    if (isUser) {
        return (
            <div className="flex gap-4 items-start justify-end">
                <div className="max-w-[80%] bg-blue-600/10 border border-blue-500/15 rounded-2xl rounded-tr-sm px-5 py-3">
                    <p className="text-sm text-gray-100 leading-relaxed">{content}</p>
                </div>
                <div className="w-8 h-8 rounded-full bg-gray-700/80 flex items-center justify-center text-[0.65rem] font-medium shrink-0 text-gray-300">
                    You
                </div>
            </div>
        )
    }

    return (
        <div className="flex gap-4 items-start">
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-xs font-bold shrink-0 shadow-md shadow-blue-500/20">
                D
            </div>
            <div className="flex-1 min-w-0">
                {/* Content */}
                <div className="prose prose-invert prose-sm max-w-none">
                    <ReactMarkdown remarkPlugins={[remarkGfm]}>{content}</ReactMarkdown>
                </div>

                {/* Chart */}
                {chart && (
                    <div className="mt-5 bg-[#12121e] rounded-xl border border-white/[0.06] p-5">
                        <DashChart spec={chart} />
                    </div>
                )}

                {/* SQL toggle */}
                {sql && (
                    <div className="mt-3">
                        <button
                            onClick={() => setShowSql(!showSql)}
                            className="text-xs text-gray-500 hover:text-gray-300 flex items-center gap-1.5 transition-colors"
                        >
                            <svg className={`w-3 h-3 transition-transform ${showSql ? 'rotate-90' : ''}`} fill="currentColor" viewBox="0 0 20 20">
                                <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clipRule="evenodd" />
                            </svg>
                            SQL Query
                        </button>
                        {showSql && (
                            <pre className="mt-2 bg-[#0d0d14] border border-white/5 rounded-lg p-3 text-xs overflow-x-auto text-gray-400">
                                <code>{sql}</code>
                            </pre>
                        )}
                    </div>
                )}
            </div>
        </div>
    )
}
