import {useEffect, useMemo, useRef, useState} from "react";
import clsx from "clsx";

export function Search({snippets, openSnippet}) {
    const searchElement = useRef(null);

    const [showResults, setShowResults] = useState<boolean>(false);
    const [query, setQuery] = useState<string>('');

    const results = useMemo(() => {
        if (snippets === undefined) {
            return []
        } else {
            return snippets.filter(snippet => snippet.title.toLowerCase().includes(query.toLowerCase()))
                .toSorted((a: string, b: string) => {
                    const titleA = a.title.toLowerCase();
                    const titleB = b.title.toLowerCase();

                    if (titleA < titleB) {
                        return -1;
                    }
                    if (titleA > titleB) {
                        return 1;
                    }
                    return 0;
                });
        }
    }, [snippets, query]);

    const [selectedResult, setSelectedResult] = useState(0)
    useEffect(() => {
        if (selectedResult > results?.length - 1) {
            setSelectedResult(Math.max(0, results?.length - 1))
        }
    }, [results]);

    function snippetSelected(snippet) {
        openSnippet(snippet);
        document?.activeElement?.blur();
    }

    function handleKey(e) {
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            setSelectedResult((selectedResult + 1) % results.length)
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            if (selectedResult > 0) {
                setSelectedResult(selectedResult - 1)
            } else {
                setSelectedResult(Math.max(0, results?.length - 1))
            }
        } else if (e.key === 'Enter' && results.length > 0) {
            e.preventDefault();
            snippetSelected(results[selectedResult])
        } else if (e.key === 'Escape') {
            searchElement.current.blur()
        }
    }

    return (
        <div className="dropdown w-full max-w-128">
            <label tabIndex={0} role="button"  className="input mx-1">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                     stroke="currentColor"
                     className="h-[1em] opacity-50">
                    <path strokeLinecap="round" strokeLinejoin="round"
                          d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"/>
                </svg>
                <input ref={searchElement} type="search" className="grow" placeholder="Search"
                       value={query} onChange={e => setQuery(e.target.value)}
                       onFocus={() => setShowResults(true)}
                       onKeyDown={(e) => handleKey(e)}/>
            </label>
            <ul tabIndex={0} className={clsx({
                "dropdown-content bg-base-100 rounded-box z-1 w-full p-2 shadow-sm mt-2 text-base-content/70": true,
                "hidden": !showResults
            })}>
                {results.map((result, index) =>
                    <li key={index} className={clsx({
                        "px-3 py-2 truncate": true,
                        "hover:bg-primary-content/70 hover:text-primary/70": selectedResult !== index,
                        "bg-primary-content text-primary": selectedResult === index
                    })}
                        onClick={() => snippetSelected(result)}>
                        <a>{result.title}</a>
                    </li>)}
                {!results.length && (<div className="text-base-content/50 italic px-2">No matches found</div>)}
            </ul>
        </div>)
}