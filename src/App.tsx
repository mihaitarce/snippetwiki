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
        <div className="flex px-3 gap-6">
            <div className="py-3" style={{width: "calc(65ch + 48px)"}}>
                <SnippetList snippets={snippets}/>
            </div>

            <div className="flex-1 h-svh sticky top-0">
                <div className="flex flex-col gap-3 h-full">
                    <div className="filter justify-end">
                        <input className="btn btn-sm btn-ghost filter-reset" type="radio" name="metaframeworks"
                               aria-label="All"/>
                        <input className="btn btn-sm btn-soft btn-success" type="radio" name="metaframeworks"
                               aria-label="HKU"></input>
                        <input className="btn btn-sm btn-soft btn-info" type="radio" name="metaframeworks"
                               aria-label="Dentistry"/>
                        <input className="btn btn-sm btn-soft btn-warning" type="radio" name="metaframeworks"
                               aria-label="Personal"/>
                        {/*<input className="btn btn-sm btn-soft bg-green-500/30 border-green-500/50" type="radio" name="metaframeworks" aria-label="HKU"></input>*/}
                        {/*<input className="btn btn-sm bg-blue-500/30 border-blue-500/50" type="radio" name="metaframeworks" aria-label="Dentistry"/>*/}
                        {/*<input className="btn btn-sm bg-yellow-500/30 border-yellow-500/50" type="radio" name="metaframeworks" aria-label="Personal"/>*/}
                    </div>
                    <h1 className="text-3xl font-bold">
                        Snippet wiki
                    </h1>
                    <div>
                        <button className="btn btn-primary" onClick={addSnippet}>Add score</button>
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

                        <input type="radio" name="my_tabs_3" className="tab" aria-label="Map"/>
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
