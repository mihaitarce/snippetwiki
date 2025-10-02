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
                    "btn-soft btn-primary": snippet.draft_created
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

        <div className="flex flex-wrap items-center justify-between gap-1 mb-1">
            <div className="flex-1 text-base-content/50">
                {new Date(snippet.modified).toLocaleDateString(undefined, {
                    weekday: "long",
                    year: "numeric",
                    month: "short",
                    day: "numeric",
                })}
            </div>

            <div className="tooltip tooltip-bottom">
                <div className="tooltip-content">
                    user1<br/>
                    user2<br/>
                    ...
                </div>
                <button className="btn btn-sm btn-ghost pointer-events-none">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1} stroke="currentColor" className="size-5">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z" />
                    </svg>
                    2
                </button>
            </div>

            <button className="btn btn-sm btn-ghost pointer-events-none">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1} stroke="currentColor" className="size-5">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                    <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                </svg>
                24
            </button>

            <div className="tooltip tooltip-bottom">
                <div className="tooltip-content">
                    user1<br/>
                    user2<br/>
                    ...
                </div>

                <button className="btn btn-sm btn-soft btn-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1} stroke="currentColor" className="size-5">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M6.633 10.25c.806 0 1.533-.446 2.031-1.08a9.041 9.041 0 0 1 2.861-2.4c.723-.384 1.35-.956 1.653-1.715a4.498 4.498 0 0 0 .322-1.672V2.75a.75.75 0 0 1 .75-.75 2.25 2.25 0 0 1 2.25 2.25c0 1.152-.26 2.243-.723 3.218-.266.558.107 1.282.725 1.282m0 0h3.126c1.026 0 1.945.694 2.054 1.715.045.422.068.85.068 1.285a11.95 11.95 0 0 1-2.649 7.521c-.388.482-.987.729-1.605.729H13.48c-.483 0-.964-.078-1.423-.23l-3.114-1.04a4.501 4.501 0 0 0-1.423-.23H5.904m10.598-9.75H14.25M5.904 18.5c.083.205.173.405.27.602.197.4-.078.898-.523.898h-.908c-.889 0-1.713-.518-1.972-1.368a12 12 0 0 1-.521-3.507c0-1.553.295-3.036.831-4.398C3.387 9.953 4.167 9.5 5 9.5h1.053c.472 0 .745.556.5.96a8.958 8.958 0 0 0-1.302 4.665c0 1.194.232 2.333.654 3.375Z" />
                    </svg>
                    12
                </button>
            </div>
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