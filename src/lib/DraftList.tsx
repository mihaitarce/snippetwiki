import {useAutoAnimate} from "@formkit/auto-animate/react";

export function DraftList({drafts, openSnippet}) {
    const [parent, enableAnimations] = useAutoAnimate();

    return (
        <div className="fixed bottom-[-4px] w-full">
            <div ref={parent} className="flex gap-2 px-4 overflow-y-hidden overflow-x-scroll">
                {drafts.map((draft) => (
                    <button className="btn btn-warning btn-sm text-nowrap" onClick={() => openSnippet(draft, true)}>
                        <svg className="size-4" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"
                             xmlns="http://www.w3.org/2000/svg">
                            <path
                                d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125"
                                strokeLinecap="round"
                                strokeLinejoin="round"/>
                        </svg>
                        {draft.draft_title ? draft.draft_title : draft.title}
                    </button>
                ))}
            </div>
        </div>)
}