import './App.css'
import {useLiveQuery} from "@tanstack/react-db";
import {SnippetList} from "./lib/SnippetList.tsx";
import {Search} from "./lib/Search"
import {ConceptMap} from "./lib/ConceptMap.tsx";
import {snippetsCollection} from "./lib/collection.ts";
import {useMemo, useState} from "react";

function App() {
    const {data: snippets} = useLiveQuery((q) =>
        q.from({snippet: snippetsCollection})
            // .where(({ score }) => eq(todo.completed, false))
            .orderBy(({snippet}) => snippet.modified, 'desc')
    );

    const [openNames, setOpenNames] = useState(['Zemira', 'Alexandre']);
    const [editingIDs, setEditingIDs] = useState([]);

    const openSnippets = useMemo(() => {
        if (snippets === undefined) {
            return []
        } else {
            return openNames.map(name => snippets.find(snippet => snippet.name === name))
                .filter(snippet => snippet !== undefined);
        }
    }, [snippets, openNames]);

    const snippetsByDate = useMemo(() => {
        if (snippets) {
            return Map.groupBy(snippets, snippet => {
                return snippet.modified.slice(0, 10)
            })
        } else {
            return new Map()
        }
    }, [snippets])

    function addSnippet() {
        const newSnippet = {
            id: crypto.randomUUID(),
            name: 'Mihai',
            value: 100,
            modified: new Date().toISOString(),
        }
        snippetsCollection.insert(newSnippet);
        openSnippet(newSnippet)
    }

    function scrollToLink(snippet) {
        setTimeout(
            () => document.getElementById(snippet.name)?.scrollIntoView({behavior: 'smooth'}),
            50
        )
    }

    function openSnippet(snippet) {
        if (!openNames.includes(snippet.name)) {
            setOpenNames([snippet.name, ...openNames]);
        }

        scrollToLink(snippet);
    }

    function closeSnippet(snippet) {
        setOpenNames(openNames.filter((name) => name !== snippet.name));
    }

    return (
        <div className="flex px-4 gap-6 flex-col items-center lg:items-start lg:flex-row">
            <div
                className="flex-none order-2 lg:order-1 mx-auto w-full max-w-[calc(65ch+3rem)] lg:w-[calc(65ch+3rem)] py-4">
                <SnippetList snippets={openSnippets} closeSnippet={closeSnippet}/>
            </div>

            <div className="flex-auto order-1 lg:order-2 w-full lg:sticky lg:top-0 lg:h-svh">
                <div className="flex flex-col gap-3 h-full">
                    <div className="filter justify-end">
                        <input className="btn btn-sm btn-ghost filter-reset" type="radio" name="bag" aria-label="All"/>
                        <input className="btn btn-sm" type="radio" name="bag" aria-label="HKU"/>
                        <input className="btn btn-sm" type="radio" name="bag" aria-label="Dentistry"/>
                        <input className="btn btn-sm btn-soft btn-warning" type="radio" name="bag"
                               aria-label="Personal"/>
                    </div>

                    <div>
                        <h1 className="text-4xl font-serif">Snippet wiki</h1>
                        <h2 className="text-xl">A collaborative knowledge base for students</h2>
                    </div>

                    <div className="flex gap-1 items-center">
                        <button className="btn btn-square btn-ghost" onClick={addSnippet}>
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                                 stroke="currentColor" className="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15"/>
                            </svg>
                        </button>

                        <label aria-label="Upload file" className="btn btn-square btn-ghost">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                                 stroke="currentColor" className="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="m18.375 12.739-7.693 7.693a4.5 4.5 0 0 1-6.364-6.364l10.94-10.94A3 3 0 1 1 19.5 7.372L8.552 18.32m.009-.01-.01.01m5.699-9.941-7.81 7.81a1.5 1.5 0 0 0 2.112 2.13"/>
                            </svg>
                            <input className="hidden" type="file"/>
                        </label>

                        {/*<div className="inline-grid *:[grid-area:1/1]">*/}
                        {/*    <div className="status status-lg status-error animate-ping"></div>*/}
                        {/*    <div className="status status-lg status-error"></div>*/}
                        {/*</div>*/}
                    </div>

                    <div>
                        <Search/>
                    </div>

                    <div className="flex-1 tabs tabs-lift tabs-sm">
                        <input type="radio" name="my_tabs_3" className="tab" aria-label="Open"/>
                        <div className="tab-content bg-base-100 border-base-300 p-4">
                            <ul>
                                {openSnippets.map((snippet) => (
                                    <li key={snippet.id} className="flex items-center gap-1">
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
                                               scrollToLink(snippet)
                                           }}>
                                            {snippet.name || "<untitled>"}
                                        </a>
                                    </li>
                                ))}
                            </ul>
                        </div>

                        <input type="radio" name="my_tabs_3" className="tab" aria-label="Recent" defaultChecked/>
                        <div className="tab-content bg-base-100 border-base-300 p-4">
                            {snippetsByDate.keys().map((snippetDate) => (
                                <div key={snippetDate} className="grid auto-cols-max" style={{ gridTemplateColumns: '8rem auto' }}>
                                    <div className="flex items-center h-8">
                                        <div className="text-base-content/50">{snippetDate}</div>
                                    </div>
                                    <ul className="mb-1">
                                        {Array.from(snippetsByDate.get(snippetDate)).map((snippet) => (
                                            <li key={snippet.id} className="flex items-center gap-2 h-8">
                                                <a className="text-blue-500"
                                                   href={`#${snippet.name}`}
                                                   onClick={(e) => {
                                                       e.preventDefault();
                                                       openSnippet(snippet)
                                                   }}>
                                                    {snippet.name || "<untitled>"}
                                                </a>
                                                {openSnippets.includes(snippet) && <button className="btn btn-square btn-sm btn-ghost"
                                                                                           onClick={() => closeSnippet(snippet)}>
                                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                                         strokeWidth={1.5} stroke="currentColor" className="size-4">
                                                        <path strokeLinecap="round" strokeLinejoin="round"
                                                              d="M6 18 18 6M6 6l12 12"/>
                                                    </svg>
                                                </button>}
                                            </li>
                                        ))}
                                    </ul>
                                </div>
                            ))}
                        </div>

                        <input type="radio" name="my_tabs_3" className="tab hidden xl:flex" aria-label="Map"/>
                        <div className="tab-content bg-base-100 border-base-300 p-4">
                            <div className="w-full h-full bg-indigo-100/30">
                                <ConceptMap/>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default App
