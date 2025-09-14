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
        <a className="text-blue-500" href={`#${snippet.name}`}
           onClick={(e) => {
               e.preventDefault();
               openSnippet(snippet);
           }}>
            {snippet.name || "<untitled>"}
        </a>
    </>)
}

export function OpenSnippets({snippets, openSnippet, closeSnippet}) {
    return (<ul>
        {snippets.map((snippet) => (
            <li key={snippet.id} className="flex items-center gap-2">
                <button className="btn btn-square btn-sm btn-ghost"
                        onClick={() => closeSnippet(snippet)}>
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                         strokeWidth={1.5} stroke="currentColor" className="size-4">
                        <path strokeLinecap="round" strokeLinejoin="round"
                              d="M6 18 18 6M6 6l12 12"/>
                    </svg>
                </button>
                <a className="text-blue-500"
                   href={`#${snippet.name}`}
                   onClick={(e) => {
                       e.preventDefault();
                       openSnippet(snippet)
                   }}>
                    {snippet.name || "<untitled>"}
                </a>
            </li>
        ))}
    </ul>)
}

export function RecentSnippets({snippetsByDate, openSnippets, openSnippet, closeSnippet}) {
    return (Array.from(snippetsByDate.keys()).map((snippetDate) => (
        <div key={snippetDate} className="grid auto-cols-max" style={{gridTemplateColumns: '6.25rem auto'}}>
            <div className="flex items-center h-8">
                <div className="text-base-content/50">{snippetDate}</div>
            </div>
            <ul className="mb-1">
                {snippetsByDate.get(snippetDate).map((snippet) => (
                    <li key={snippet.id} className="flex items-center gap-2">
                        <SnippetItem snippet={snippet} isOpen={openSnippets.includes(snippet)}
                                     openSnippet={openSnippet} closeSnippet={closeSnippet}/>
                    </li>
                ))}
            </ul>
        </div>)
    ))
}