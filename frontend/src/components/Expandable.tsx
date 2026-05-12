import { useState } from 'react';
import { ChevronRight } from 'lucide-react';

interface Props {
    icon: string;
    title: string;
    defaultOpen?: boolean;
    children: React.ReactNode;
}

export default function Expandable({ icon, title, defaultOpen = false, children }: Props) {
    const [open, setOpen] = useState(defaultOpen);

    return (
        <div className="expandable">
            <div className="expandable-header" onClick={() => setOpen(!open)}>
                <ChevronRight size={12} className={`chevron ${open ? 'open' : ''}`} />
                <span>{icon}</span>
                <span>{title}</span>
            </div>
            {open && <div className="expandable-body">{children}</div>}
        </div>
    );
}
