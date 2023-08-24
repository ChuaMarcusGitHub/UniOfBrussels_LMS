import React, {
    useEffect,
    useLayoutEffect,
    useMemo,
    useRef,
    useState,
} from "react";

// Component Imports
import "./RecipientsDisplay.css";

// --- Interfaces
export interface IRecipientsDisplayProps {
    recipients?: string[];
}

export interface IWindowDimensions {
    width: number;
    height: number;
}

const ELIPSIS = "...";
const SEPARATOR = ", ";

// ----- Styles
const badge: React.CSSProperties = {
    "font-size": 16,
    color: "#f0f0f0",
    "background-color": "#666666",
    "border-radius": "3px",
    padding: "2px 5px",
};
const text: React.CSSProperties = {
    "text-overflow": "ellipsis",
    "white-space": "nowrap",
    "overflow-x": "scroll",
};
const cell = {
    display: "flex",
    "justify-content": "space-between",
    "align-items": "center",

    "font-size": 16,
    color: "#333333",
    "border-radius": "3px",
    padding: "5px 10px",

    "text-overflow": "ellipsis",
    "white-space": "nowrap",
    "overflow-x": "scroll",
};

///------

export default function RecipientsDisplay(props: IRecipientsDisplayProps) {
    // --- Constants
    const cellRef = useRef(null);

    let resizeTimeoutId = null;

    // --- UseState Initializers
    const [showBadge, setShowBadge] = useState(false);
    const [hiddenRecipients, setHiddenRecipients] = useState<string[]>([]);
    const [recipientString, setRecipientString] = useState("");
    const [windowDimensions, setWindowDimensions] = useState<IWindowDimensions>(
        { width: window.innerWidth, height: window.innerHeight }
    );

    // --- Load Effect
    useEffect(() => {
        // Guard
        if (props.recipients.length === 0) return;

        // Add the recipient string
        adjustRecipientString();

        // event listeners
        window.addEventListener("resize", updateWindowDimensions);

        return () => {
            window.removeEventListener("resize", updateWindowDimensions);
        };
    }, []);

    // Necessary for triggering clipping of  extra emails
    useEffect(() => {
        if (isOverflowActive(cellRef || null)) {
            adjustRecipientString();
        }
    }, [recipientString]);

    useEffect(() => {
        setShowBadge(hiddenRecipients?.length > 0);
    }, [hiddenRecipients]);

    useEffect(() => {
        adjustRecipientString();
    }, [windowDimensions.width]);

    // --- Window Effect -> Tracks window change

    // --- Component Methods
    const updateWindowDimensions = () => {
        // clear any existing timeout
        if (resizeTimeoutId) clearTimeout(resizeTimeoutId);

        resizeTimeoutId = setTimeout(() => {
            setWindowDimensions({
                width: window.innerWidth,
                height: window.innerHeight,
            });
            clearTimeout(resizeTimeoutId);
        }, 200);
    };

    /*  
        Note: Although these two methods are placed in the local component, 
        the utility of this component could be expanded upon and should rightly be placed in the
        feature's utility file (e.g. 'RecipientUtility' or 'ElementUtility')
    */
    const adjustRecipientString = () => {
        const cellCopy = cellRef;

        if (!isOverflowActive(cellCopy || null)) {
            const _localRecipients = [...props.recipients];
            setRecipientString(_localRecipients.join(SEPARATOR));
            setHiddenRecipients([]);
        } else {
            // overFlow
            const recepientArray = recipientString.split(SEPARATOR);
            // peek at last item
            const peek = recepientArray[recepientArray.length - 1];
            if (peek === recepientArray[0])
                // last item is first item, but still overflow
                return;

            if (peek === ELIPSIS) {
                // last item left
                recepientArray.pop(); // remove the elipsis
            }
            let newHiddenRecipient = "";

            if (recepientArray.length !== 1) {
                newHiddenRecipient = recepientArray.pop();
                const newHiddenRecipients = [...hiddenRecipients];
                newHiddenRecipients.unshift(newHiddenRecipient);
                setHiddenRecipients(newHiddenRecipients);
            }

            recepientArray.push(ELIPSIS);
            //update the new recipient string
            setRecipientString(recepientArray.join(SEPARATOR));
        }
    };

    const isOverflowActive = (e) => {
        if (!e) return false;
        let diff = e.current.scrollWidth - e.current.clientWidth;

        // To cater for edge condition where scrollWidth === clientWidth
        // Causes fied to go empty
        // const isNotEmpty = (e.current.scrollWidth !== 0 || e.current.clientWidth !== 0)
        // return diff > 0 ? true : (diff === 0 && isNotEmpty) ?? false;
        return e.current.scrollWidth > e.current.clientWidth;
    };

    // --- Render Methods
    const renderComponent = () => {
        return (
            <div style={cell}>
                <span style={text} ref={cellRef}>
                    {recipientString}
                </span>
                {showBadge && (
                    <div style={badge}>+ {hiddenRecipients.length}</div>
                )}
            </div>
        );
    };

    return renderComponent();
}

