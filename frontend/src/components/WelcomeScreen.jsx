const SUGGESTIONS = [
    { icon: '📊', text: 'Total store revenue for 2001?', desc: 'Revenue metrics' },
    { icon: '🔄', text: 'Compare all 3 channels by profit', desc: 'Channel analysis' },
    { icon: '🏆', text: 'Top 10 items by category in 2001', desc: 'Product rankings' },
    { icon: '📦', text: 'Low inventory across warehouses', desc: 'Inventory alerts' },
    { icon: '🔁', text: 'What is the return rate for store sales?', desc: 'Return analysis' },
    { icon: '🛠️', text: 'Create a monthly revenue view', desc: 'Build infrastructure' },
]

export default function WelcomeScreen({ onSend }) {
    return (
        <div className="flex-1 flex flex-col items-center justify-center px-6">
            {/* Hero */}
            <div className="max-w-3xl w-full text-center mb-12">
                <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-blue-500 via-purple-500 to-blue-600 flex items-center justify-center text-2xl font-bold mx-auto mb-6 shadow-lg shadow-blue-500/20">
                    D
                </div>
                <h1 className="text-3xl font-semibold text-gray-50 mb-3 tracking-tight">
                    What can I help you analyze?
                </h1>
                <p className="text-base text-gray-400 max-w-lg mx-auto leading-relaxed">
                    Query store sales, returns, promotions, inventory, and customer demographics
                    across store, catalog, and web channels.
                </p>
            </div>

            {/* Suggestion cards */}
            <div className="max-w-3xl w-full grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 mb-10">
                {SUGGESTIONS.map((s) => (
                    <button
                        key={s.text}
                        onClick={() => onSend(s.text)}
                        className="text-left px-4 py-4 rounded-xl border border-white/[0.06] bg-white/[0.02] hover:bg-white/[0.05] hover:border-white/[0.12] hover:shadow-lg hover:shadow-blue-500/5 transition-all group"
                    >
                        <div className="flex items-start gap-3">
                            <span className="text-lg mt-0.5">{s.icon}</span>
                            <div>
                                <p className="text-sm text-gray-300 group-hover:text-gray-100 transition-colors leading-snug">
                                    {s.text}
                                </p>
                                <p className="text-[0.65rem] text-gray-600 mt-1">{s.desc}</p>
                            </div>
                        </div>
                    </button>
                ))}
            </div>

            {/* Input */}
            <form
                onSubmit={(e) => {
                    e.preventDefault()
                    const input = e.target.elements.welcomeInput.value.trim()
                    if (input) onSend(input)
                }}
                className="max-w-3xl w-full"
            >
                <div className="relative">
                    <input
                        name="welcomeInput"
                        type="text"
                        placeholder="Ask anything about your retail data..."
                        className="w-full bg-[#141420] border border-white/10 rounded-xl px-5 py-4 pr-14 text-sm text-gray-100 placeholder-gray-600 focus:outline-none focus:border-blue-500/50 focus:ring-1 focus:ring-blue-500/20 transition-all shadow-lg shadow-black/20"
                    />
                    <button
                        type="submit"
                        className="absolute right-3 top-1/2 -translate-y-1/2 w-9 h-9 flex items-center justify-center rounded-lg bg-blue-600 hover:bg-blue-500 text-white text-sm font-medium transition-colors"
                    >
                        ↑
                    </button>
                </div>
            </form>

            <div className="flex items-center gap-4 mt-6">
                <span className="text-[0.6rem] text-gray-600">Strands Agents</span>
                <span className="w-1 h-1 rounded-full bg-gray-700"></span>
                <span className="text-[0.6rem] text-gray-600">Snowflake</span>
                <span className="w-1 h-1 rounded-full bg-gray-700"></span>
                <span className="text-[0.6rem] text-gray-600">ChromaDB</span>
            </div>
        </div>
    )
}
