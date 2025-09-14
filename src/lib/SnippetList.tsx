import {scoresCollection} from "./collection.ts";

export function SnippetList({snippets}) {
    function updateSnippet(snippet) {
        scoresCollection.update(snippet.id, (draft) => {
            draft.value = 55;
        })
    }

    function deleteSnippet(snippet) {
        scoresCollection.delete(snippet.id)
    }

    return (
        <ul className="flex flex-col gap-4">
            {snippets.map((snippet) =>
                <li key={snippet.id} className="card bg-base-100 p-6">
                    <div className="flex items-center justify-between mb-4">
                        <h1 className="font-serif text-3xl">{snippet.name}: {snippet.value}</h1>
                        <div className="flex gap-3">
                            <button className="btn" onClick={() => updateSnippet(snippet)}>Update</button>
                            <button className="btn btn-error" onClick={() => deleteSnippet(snippet)}>Delete</button>
                        </div>
                    </div>

                    <div className="prose prose-headings:font-serif prose-headings:font-normal prose-headings:my-2">
                        <h2>Hello, world!</h2>
                        <p>
                            Et eligendi aut cupiditate voluptatibus quia sit architecto. Ut suscipit facere rerum ut et
                            repellat. Distinctio non officiis commodi iste repellendus aut.
                        </p>
                        <p>
                            In et voluptas non modi. Ut asperiores et voluptatem consectetur. Ducimus asperiores
                            laudantium
                            enim. Eius rerum illo ut. Necessitatibus deserunt aspernatur sapiente aliquid harum nihil.
                        </p>
                    </div>
                </li>
            )}
        </ul>
    )
}