import './App.css'
import {Search} from "./lib/Search"
import {scoresCollection} from "./lib/collection.ts";
import {useLiveQuery} from "@tanstack/react-db";
import {SnippetList} from "./lib/SnippetList.tsx";
import {ConceptMap} from "./lib/ConceptMap.tsx";

function App() {
    const {data: snippets} = useLiveQuery((q) =>
        q.from({score: scoresCollection})
            // .where(({ score }) => eq(todo.completed, false))
            .orderBy(({score}) => score.value, 'desc')
    );

    function addSnippet() {
        scoresCollection.insert({
            id: crypto.randomUUID(),
            name: 'Mihai',
            value: 100
        });
    }

    return (
        <div className="flex px-4 gap-6 flex-col items-center lg:items-start lg:flex-row">
            <div className="flex-none order-2 lg:order-1 mx-auto w-full max-w-[calc(65ch+3rem)] lg:w-[calc(65ch+3rem)] py-4">
                <SnippetList snippets={snippets}/>
            </div>

            <div className="flex-auto order-1 lg:order-2 w-full lg:sticky lg:top-0 lg:h-svh">
                <div className="flex flex-col gap-3 h-full">
                    <div className="filter justify-end">
                        <input className="btn btn-sm btn-ghost filter-reset" type="radio" name="bag" aria-label="All"/>
                        <input className="btn btn-sm" type="radio" name="bag" aria-label="HKU"/>
                        <input className="btn btn-sm" type="radio" name="bag" aria-label="Dentistry"/>
                        <input className="btn btn-sm btn-soft btn-warning" type="radio" name="bag" aria-label="Personal"/>
                    </div>

                    <div>
                        <h1 className="text-4xl font-serif">Snippet wiki</h1>
                        <h2 className="text-xl">A collaborative knowledge base for students</h2>
                    </div>

                    <div>
                        <button className="btn btn-square btn-ghost" onClick={addSnippet}>
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                            </svg>
                        </button>
                    </div>

                    <Search/>

                    {/* name of each tab group should be unique */}
                    <div className="tabs tabs-lift tabs-sm flex-1">
                        {/*<div className="flex-1 card bg-base-100 p-4">*/}
                        <input type="radio" name="my_tabs_3" className="tab" aria-label="Open"/>
                        <div className="tab-content bg-base-100 border-base-300 p-4">
                            Open snippets
                        </div>

                        <input type="radio" name="my_tabs_3" className="tab" aria-label="Recent" defaultChecked/>
                        <div className="tab-content bg-base-100 border-base-300 p-4">
                            Recent snippets
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
