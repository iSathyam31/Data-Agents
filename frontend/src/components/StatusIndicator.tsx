interface Props {
    icon: string;
    label: string;
}

export default function StatusIndicator({ icon, label }: Props) {
    return (
        <div className="status-indicator">
            <span className="icon">{icon}</span>
            <span className="label">{label}</span>
            <span className="pulse-dot" />
        </div>
    );
}
