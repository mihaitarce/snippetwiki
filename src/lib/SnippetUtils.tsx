import {useMemo} from "react";

function SnippetCloseButton({snippet, isOpen, closeSnippet}) {
    if (isOpen) {
        return (<button className="btn btn-square btn-sm btn-ghost"
                        onClick={() => closeSnippet(snippet)}>
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                 strokeWidth={1.5} stroke="currentColor" className="size-4">
                <path strokeLinecap="round" strokeLinejoin="round"
                      d="M6 18 18 6M6 6l12 12"/>
            </svg>
        </button>)
    }

    return (<div className="w-8 h-8"></div>)
}

function SnippetItem({snippet, isOpen, openSnippet, closeSnippet}) {
    return (<>
        <SnippetCloseButton snippet={snippet} isOpen={isOpen} closeSnippet={closeSnippet}/>
        <a className="text-blue-500" href={`#${snippet.title}`}
           onClick={(e) => {
               e.preventDefault();
               openSnippet(snippet);
           }}>
            {snippet.title || "<untitled>"}
        </a>
        {snippet.draft_created &&
            <svg className="size-4 text-base-content/50 ms-1" fill="none"
                 stroke="currentColor" strokeWidth="1.5" viewBox="0 0 24 24"
                 xmlns="http://www.w3.org/2000/svg">
                <path
                    d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125"
                    strokeLinecap="round"
                    strokeLinejoin="round"/>
            </svg>}
    </>)
}

export function OpenSnippets({snippets, openSnippet, closeSnippet, closeAllSnippets}) {
    if (snippets.length === 0) {
        return (<div className="text-base-content/50">
            No open snippets
        </div>)
    }

    return (<ul>
        {snippets.map((snippet) => (
            <li key={snippet.id} className="flex items-center gap-2">
                <SnippetItem snippet={snippet} isOpen={snippets.includes(snippet)}
                             openSnippet={openSnippet} closeSnippet={closeSnippet}/>
            </li>
        ))}
        {snippets.length > 1 && <li>
            <button className="btn mt-2" onClick={closeAllSnippets}>
                Close all
            </button>
        </li>}
    </ul>)
}

export function RecentSnippets({snippets, openSnippets, openSnippet, closeSnippet}) {
    const groupedByDate = useMemo(() => {
        // ES2024: return Map.groupBy(snippets, snippet => snippet.modified.slice(0, 10))
        return snippets.reduce((acc: Map<string, T[]>, snippet: T) => {
            const modified = snippet.modified.slice(0, 10)
            if (!acc.has(modified)) {
                acc.set(modified, []);
            }
            acc.get(modified).push(snippet);
            return acc;
        }, new Map());
    }, [snippets])

    if (snippets.length === 0) {
        return (<div className="text-base-content/50">
            No recent snippets
        </div>)
    }

    return (Array.from(groupedByDate.keys()).map((snippetDate) => (
        <div key={snippetDate} className="grid auto-cols-max" style={{gridTemplateColumns: '6.25rem auto'}}>
            <div className="flex items-center h-8">
                <div className="text-base-content/50">{snippetDate}</div>
            </div>
            <ul>
                {groupedByDate.get(snippetDate).map((snippet) => (
                    <li key={snippet.id} className="flex items-center gap-2">
                        <SnippetItem snippet={snippet} isOpen={openSnippets.includes(snippet)}
                                      openSnippet={openSnippet} closeSnippet={closeSnippet}/>
                    </li>
                ))}
            </ul>
        </div>)
    ))
}