import './App.css'
import {Search} from "./lib/Search"
import {scoresCollection} from "./lib/collection.ts";
import {useLiveQuery} from "@tanstack/react-db";
import { SnippetList } from "./lib/SnippetList.tsx";

function App() {
    const { data: snippets } = useLiveQuery((q) =>
        q.from({ score: scoresCollection })
            // .where(({ score }) => eq(todo.completed, false))
            .orderBy(({ score }) => score.value, 'desc')
    );

    function addScore() {
        scoresCollection.insert({
            id: crypto.randomUUID(),
            name: 'Mihai',
            value: 100
        });
    }

    return (
        <div className="flex">
            <div className="flex-1 p-4 max-w-[65ch]">
                <SnippetList snippets={snippets} />
            </div>

            <div className="flex-1 p-4 h-svh sticky top-0">
                <div className="flex flex-col gap-4 h-full">
                    <h1 className="text-3xl font-bold">
                        Hello world!
                    </h1>
                    <div>
                        <button className="btn btn-primary" onClick={addScore}>Add score</button>
                    </div>

                    <Search/>

                    <div className="flex-1 card bg-base-100 p-4">
                        <div className="w-full h-full bg-indigo-100">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default App
