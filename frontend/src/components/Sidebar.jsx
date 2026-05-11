export default function Sidebar({ onClear, onSampleClick }) {
    return (
        <aside className="w-72 min-w-[280px] bg-[#0d0d14] border-r border-white/[0.06] flex flex-col h-full">
            {/* Brand header */}
            <div className="px-5 pt-5 pb-4 border-b border-white/[0.04]">
                <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-sm font-bold shadow-lg shadow-blue-500/20">
                        D
                    </div>
                    <div>
                        <h1 className="text-sm font-semibold text-gray-100">Dash</h1>
                        <p className="text-[0.6rem] text-gray-500">Self-learning Data Agent</p>
                    </div>
                </div>
            </div>

            {/* New Chat button */}
            <div className="px-4 pt-4 pb-2">
                <button
                    onClick={onClear}
                    className="w-full flex items-center gap-2 px-3 py-2.5 text-xs text-gray-300 bg-white/[0.03] hover:bg-white/[0.06] border border-white/[0.06] hover:border-white/[0.1] rounded-lg transition-all"
                >
                    <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                    </svg>
                    New Chat
                </button>
            </div>

            {/* Info section */}
            <div className="flex-1 overflow-y-auto px-4 py-3 space-y-5">
                {/* Agents */}
                <div>
                    <p className="text-[0.6rem] font-semibold uppercase tracking-widest text-gray-500 mb-2.5 px-1">
                        Agents
                    </p>
                    <div className="space-y-1.5">
                        <div className="flex items-center gap-2.5 px-3 py-2 rounded-lg bg-blue-500/[0.06] border border-blue-500/10">
                            <span className="w-2 h-2 rounded-full bg-blue-400"></span>
                            <span className="text-xs text-blue-300 font-medium">Leader</span>
                            <span className="text-[0.6rem] text-gray-500 ml-auto">Routes</span>
                        </div>
                        <div className="flex items-center gap-2.5 px-3 py-2 rounded-lg bg-green-500/[0.06] border border-green-500/10">
                            <span className="w-2 h-2 rounded-full bg-green-400"></span>
                            <span className="text-xs text-green-300 font-medium">Analyst</span>
                            <span className="text-[0.6rem] text-gray-500 ml-auto">Queries</span>
                        </div>
                        <div className="flex items-center gap-2.5 px-3 py-2 rounded-lg bg-amber-500/[0.06] border border-amber-500/10">
                            <span className="w-2 h-2 rounded-full bg-amber-400"></span>
                            <span className="text-xs text-amber-300 font-medium">Engineer</span>
                            <span className="text-[0.6rem] text-gray-500 ml-auto">Builds</span>
                        </div>
                    </div>
                </div>

                {/* Data source */}
                <div>
                    <p className="text-[0.6rem] font-semibold uppercase tracking-widest text-gray-500 mb-2.5 px-1">
                        Data Source
                    </p>
                    <div className="px-3 py-2.5 rounded-lg bg-white/[0.02] border border-white/[0.04]">
                        <div className="flex items-center justify-between mb-1.5">
                            <span className="text-xs text-gray-300">Snowflake</span>
                            <span className="w-1.5 h-1.5 rounded-full bg-green-400"></span>
                        </div>
                        <p className="text-[0.6rem] text-gray-500 leading-relaxed">
                            TPC-DS SF100TCL · 24 tables · 100TB scale
                        </p>
                    </div>
                </div>

                {/* Capabilities */}
                <div>
                    <p className="text-[0.6rem] font-semibold uppercase tracking-widest text-gray-500 mb-2.5 px-1">
                        Capabilities
                    </p>
                    <div className="space-y-1.5 text-[0.7rem] text-gray-400 px-1">
                        <p className="flex items-center gap-2">
                            <span className="text-blue-400">●</span> Revenue & sales analysis
                        </p>
                        <p className="flex items-center gap-2">
                            <span className="text-green-400">●</span> Return rate metrics
                        </p>
                        <p className="flex items-center gap-2">
                            <span className="text-purple-400">●</span> Customer demographics
                        </p>
                        <p className="flex items-center gap-2">
                            <span className="text-amber-400">●</span> Inventory monitoring
                        </p>
                        <p className="flex items-center gap-2">
                            <span className="text-pink-400">●</span> Promotion effectiveness
                        </p>
                        <p className="flex items-center gap-2">
                            <span className="text-cyan-400">●</span> View & table creation
                        </p>
                    </div>
                </div>

                {/* Quick questions */}
                <div>
                    <p className="text-[0.6rem] font-semibold uppercase tracking-widest text-gray-500 mb-2.5 px-1">
                        Try asking
                    </p>
                    <div className="space-y-1">
                        {[
                            'Total store revenue for 2001?',
                            'Compare channels by profit',
                            'Top 10 items by revenue',
                            'Return rate for store sales?',
                            'Low inventory alerts',
                        ].map((q) => (
                            <button
                                key={q}
                                onClick={() => onSampleClick(q)}
                                className="block w-full text-left text-[0.7rem] text-gray-500 hover:text-gray-200 hover:bg-white/[0.03] rounded-md px-3 py-2 transition-colors leading-snug"
                            >
                                {q}
                            </button>
                        ))}
                    </div>
                </div>
            </div>

            {/* Footer */}
            <div className="px-5 py-3 border-t border-white/[0.04]">
                <div className="flex items-center justify-center gap-2 text-[0.55rem] text-gray-600">
                    <span>Strands Agents</span>
                    <span className="w-0.5 h-0.5 rounded-full bg-gray-700"></span>
                    <span>Snowflake</span>
                    <span className="w-0.5 h-0.5 rounded-full bg-gray-700"></span>
                    <span>ChromaDB</span>
                </div>
            </div>
        </aside>
    )
}
