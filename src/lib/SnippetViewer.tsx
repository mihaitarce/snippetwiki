import clsx from "clsx";

export function SnippetViewer({snippet, edit, close}) {
    // import {Crepe} from "@milkdown/crepe";
    // import {Editor} from "@milkdown/kit/core";
    // import {replaceAll} from "@milkdown/kit/utils";
    // import {listenerCtx} from "@milkdown/plugin-listener";
    //
    // let { article } = $props();
    //
    // let editor: Editor
    // let initialized = $state(false)
    //
    // async function milkdown(dom) {
    //     const crepe = new Crepe({root: dom});
    //     crepe.setReadonly(true);
    //     editor = crepe.editor;
    // }
    //
    // $effect(() => {
    //     if (article.latest_revision && editor) {
    //         editor.config((ctx) => {
    //             ctx.get(listenerCtx).mounted(replaceAll(article.latest_revision.content));
    //         });
    //         editor.create();
    //         initialized = true;
    //     }
    // })

    function viewRevisions() {
        // ..
    }

    return (<div className="card-body">
        <div className="flex flex-wrap items-center justify-between gap-3 mb-1">
            <h1 className="text-3xl font-serif">
                {snippet.title}
            </h1>
            <div className="flex gap-1">
                <button className="btn btn-square btn-ghost text-base-content/50 hover:text-base-content">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                         strokeWidth={1} stroke="currentColor" className="size-6 inline">
                        <path strokeLinecap="round" strokeLinejoin="round"
                              d="M5.25 8.25h15m-16.5 7.5h15m-1.8-13.5-3.9 19.5m-2.1-19.5-3.9 19.5"/>
                    </svg>
                </button>
                {snippet.revision__version &&
                    <button className="btn btn-square btn-ghost text-base-content/50 hover:text-base-content"
                            aria-label="History" onClick={viewRevisions}>
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                             strokeWidth={1} stroke="currentColor" className="size-6">
                            <path strokeLinecap="round" strokeLinejoin="round"
                                  d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/>
                        </svg>
                    </button>}
                <button className="btn btn-square btn-ghost text-base-content/50 hover:text-base-content">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                         strokeWidth={1} stroke="currentColor" className="size-6">
                        <path strokeLinecap="round" strokeLinejoin="round"
                              d="M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 0 1-.825-.242m9.345-8.334a2.126 2.126 0 0 0-.476-.095 48.64 48.64 0 0 0-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0 0 11.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155"/>
                    </svg>
                </button>
                <button className={clsx({
                    "btn btn-square": true,
                    "btn-ghost border-0 text-base-content/50 hover:text-base-content": !snippet.draft_created,
                    "btn-primary": snippet.draft_created
                })}
                        aria-label="Edit"
                        onClick={() => edit(snippet)}>
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                         strokeWidth={1} stroke="currentColor" className="size-6">
                        <path strokeLinecap="round" strokeLinejoin="round"
                              d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125"/>
                    </svg>
                </button>

                <button className="btn btn-square btn-ghost text-base-content/50 hover:text-base-content"
                        onClick={() => close(snippet)}>
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                         strokeWidth={1} stroke="currentColor" className="size-6">
                        <path strokeLinecap="round" strokeLinejoin="round"
                              d="M6 18 18 6M6 6l12 12"/>
                    </svg>
                </button>
            </div>
        </div>

        <div className="mb-1 text-base-content/50">
            {new Date(snippet.modified).toDateString()}
            &nbsp;
            {new Date(snippet.modified).toLocaleTimeString(undefined, {hour: "2-digit", minute: "2-digit"})}
        </div>

        {snippet.revision__version &&
            // <div class="w-full viewer" use:milkdown></div>
            <div className="prose prose-headings:font-serif prose-headings:font-normal prose-headings:my-2">
                {snippet.revision__content}
            </div>}
        {!snippet.revision__version &&
            <div className="p-6 text-base-content/30 text-lg text-center">
                No content added
            </div>}
    </div>)
}