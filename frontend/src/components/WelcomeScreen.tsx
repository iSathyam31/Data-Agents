const SUGGESTIONS = [
    { icon: '📊', text: 'Compare total revenue across store, catalog, and web channels for 2001' },
    { icon: '🏪', text: 'Which store had the highest net profit in 2001?' },
    { icon: '🔄', text: 'What is the net loss from returns broken down by sales channel?' },
    { icon: '📦', text: 'Show me the top 10 best selling items by total revenue in 2001' },
    { icon: '👥', text: 'Break down store sales revenue by customer income band for 2001' },
    { icon: '🎯', text: 'Which promotions generated the highest incremental revenue in 2001?' },
];

interface Props {
    onSelect: (text: string) => void;
}

export default function WelcomeScreen({ onSelect }: Props) {
    return (
        <div className="welcome-container">
            <h1 className="welcome-heading">Dash</h1>
            <p className="welcome-sub">
                Self-learning data agent for Snowflake. Ask questions about your data
                and get instant insights with visualizations.
            </p>

            <div className="suggestions-grid">
                {SUGGESTIONS.map((s, i) => (
                    <button key={i} className="suggestion-card" onClick={() => onSelect(s.text)}>
                        <span className="suggestion-icon">{s.icon}</span>
                        <span className="suggestion-text">{s.text}</span>
                    </button>
                ))}
            </div>
        </div>
    );
}
