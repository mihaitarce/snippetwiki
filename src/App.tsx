import './App.css'
import {useLiveQuery} from "@tanstack/react-db";
import {SnippetList} from "./lib/SnippetList.tsx";
import {Search} from "./lib/Search"
import {ConceptMap} from "./lib/ConceptMap.tsx";
import {snippetsCollection} from "./lib/collection.ts";
import {useMemo, useState} from "react";
import {OpenSnippets, RecentSnippets} from "./lib/SnippetItem.tsx";

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

    function updateSnippet(snippet) {
        snippetsCollection.update(snippet.id, (draft) => {
            draft.value = 55;
        })
    }

    function deleteSnippet(snippet) {
        snippetsCollection.delete(snippet.id)
    }

    function openSnippet(snippet) {
        if (!openNames.includes(snippet.name)) {
            setOpenNames([snippet.name, ...openNames]);
        }
        setTimeout(() => scrollTo(snippet))
    }

    function scrollTo(snippet) {
        document.getElementById(snippet.name)?.scrollIntoView({behavior: 'smooth'})
    }

    function closeSnippet(snippet) {
        setOpenNames(openNames.filter((name) => name !== snippet.name));
    }

    return (
        <div className="flex px-4 gap-6 flex-col items-center lg:items-start lg:flex-row">
            <div
                className="flex-none order-2 lg:order-1 mx-auto w-full max-w-[calc(65ch+3rem)] lg:w-[calc(65ch+3rem)] py-4">
                <SnippetList snippets={openSnippets} closeSnippet={closeSnippet}
                             updateSnippet={updateSnippet} deleteSnippet={deleteSnippet}/>
            </div>

            <div className="flex-auto order-1 lg:order-2 w-full lg:sticky lg:top-0 lg:h-svh overflow-y-scroll">
                <div className="flex flex-col gap-3 h-full">
                    <div className="filter justify-end">
                        <input className="btn btn-sm btn-ghost filter-reset" type="radio" name="bag" aria-label="All"/>
                        <input className="btn btn-sm" type="radio" name="bag" aria-label="HKU"/>
                        <input className="btn btn-sm" type="radio" name="bag" aria-label="Dentistry"/>
                        <input className="btn btn-sm btn-soft btn-warning" type="radio" name="bag"
                               aria-label="Personal"/>
                    </div>

                    <div className="flex items-top gap-6">
                        <img src="/logo.svg" alt="snippetswiki logo" className="h-12" />
                        <div>
                            <h1 className="text-4xl font-serif my-1">Snippet wiki</h1>
                            <h2 className="text-xl text-base-content/70">Collaborative knowledge building</h2>
                        </div>
                    </div>

                    <div className="flex items-center gap-4">
                        <div className="flex gap-1">
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
                        </div>

                        <Search/>

                        {/*<div className="inline-grid *:[grid-area:1/1]">*/}
                        {/*    <div className="status status-lg status-error animate-ping"></div>*/}
                        {/*    <div className="status status-lg status-error"></div>*/}
                        {/*</div>*/}
                    </div>

                    <div className="ms-1">
                    </div>

                    <div className="flex-1 tabs tabs-lift tabs-sm">
                        <input type="radio" name="my_tabs_3" className="tab" aria-label="Open"/>
                        <div className="tab-content bg-base-100 border-base-300 p-4">
                            <OpenSnippets snippets={openSnippets}
                                          openSnippet={openSnippet} closeSnippet={closeSnippet}/>
                        </div>

                        <input type="radio" name="my_tabs_3" className="tab" aria-label="Recent" defaultChecked/>
                        <div className="tab-content bg-base-100 border-base-300 p-4">
                            <RecentSnippets snippets={snippets} openSnippets={openSnippets}
                                            openSnippet={openSnippet} closeSnippet={closeSnippet}/>
                        </div>

                        <input type="radio" name="my_tabs_3" className="tab hidden xl:flex" aria-label="Map"/>
                        <div className="tab-content bg-base-100 border-base-300 p-4">
                            <div className="w-full h-full bg-base-200">
                                {snippets.length && <ConceptMap snippets={snippets}/>}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default App
