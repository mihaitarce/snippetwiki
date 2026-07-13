import { useEffect, useState } from "react";

// The root layout stamps data-theme="light"|"dark" on <html>, or removes the
// attribute for "system" (see root.html.heex). Resolve to the effective theme
// so BlockNote islands follow the app theme.
function currentTheme() {
    const attr = document.documentElement.getAttribute("data-theme");
    if (attr === "dark" || attr === "light") {
        return attr;
    }
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

export function useAppTheme() {
    const [theme, setTheme] = useState(() => currentTheme());

    useEffect(() => {
        const observer = new MutationObserver(() => setTheme(currentTheme()));
        observer.observe(document.documentElement, {
            attributes: true,
            attributeFilter: ["data-theme"]
        });

        const mq = window.matchMedia("(prefers-color-scheme: dark)");
        const onChange = () => setTheme(currentTheme());
        mq.addEventListener("change", onChange);

        return () => {
            observer.disconnect();
            mq.removeEventListener("change", onChange);
        };
    }, []);

    return theme;
}
