import {useState} from 'react'
import './App.css'
import { Snippet } from "./lib/Snippet"
import { Search } from "./lib/Search"

function App() {
    // const [count, setCount] = useState(0)

    const snippets = [
        { id: 1, name: 'John', value: 1 },
        { id: 2, name: 'Michael', value: 2 },
        { id: 3, name: 'Sarah', value: 3 },
    ]

    function addScore() {
        console.log("Adding...")
    }

    return (
        <div className="flex">
            <div className="flex-1 p-4 max-w-[65ch]">
                <ul className="flex flex-col gap-4">
                    {snippets.map((snippet) =>
                        <Snippet key={snippet.id} snippet={snippet} />
                    )}
                </ul>
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
                        <div className="w-full h-full bg-indigo-100"></div>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default App
