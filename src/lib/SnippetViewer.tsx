export function SnippetViewer({snippet, edit, close}) {
    return (<div className="card-body">
        <div className="flex items-center justify-between mb-1">
            <h1 className="font-serif text-3xl">{snippet.title}</h1>
            <div className="flex gap-3">
                <button
                    className="btn btn-square btn-ghost border-0 text-base-content/50 hover:text-base-content"
                    onClick={() => edit(snippet)}>
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                         strokeWidth={1.5} stroke="currentColor" className="size-6">
                        <path strokeLinecap="round" strokeLinejoin="round"
                              d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125"/>
                    </svg>
                </button>

                <button
                    className="btn btn-square btn-ghost border-0 text-base-content/50 hover:text-base-content"
                    onClick={() => close(snippet)}>
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                         strokeWidth={1.5} stroke="currentColor" className="size-6">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M6 18 18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>
        </div>

        <div className="mb-1 text-base-content/50">
            {new Date(snippet.modified).toDateString()}
            &nbsp;
            {new Date(snippet.modified).toLocaleTimeString(undefined, {hour: "2-digit", minute: "2-digit"})}
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
    </div>)
}