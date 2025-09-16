import {Crepe} from "@milkdown/crepe";
import {Milkdown, MilkdownProvider, useEditor} from "@milkdown/react";

import "@milkdown/crepe/theme/common/style.css";
import "@milkdown/crepe/theme/frame.css";
import {useState} from "react";

function CrepeEditor({content}) {
    const {get} = useEditor((root) => {
        return new Crepe({
            root,
            defaultValue: content
        });
    });

    return <Milkdown/>;
};

export function SnippetEditor({snippet, deleteSnippet, discard, save}) {
    const [confirmDelete, setConfirmDelete] = useState(false);

    function discardChanges() {
        if (confirmDelete) {
            setConfirmDelete(false)
        } else {
            discard(snippet)
            // discard(snippet, usersPresent.length > 0)
            //
            // wsProvider.disconnect()
            // collabService.disconnect()
        }
    }

    function saveChanges() {
        save(snippet)
        // save(crepe.getMarkdown(), usersPresent.length > 0)
        //
        // wsProvider.disconnect()
        // collabService.disconnect()
    }

    return (
        <div className="card-body">
            <div className="flex items-center justify-between mb-1">
                <h1 className="font-serif text-3xl">{snippet.title}</h1>
                <div className="flex gap-3">
                    {!confirmDelete &&
                        <button aria-label="Delete" className="btn btn-square btn-outline border-0 btn-error"
                                onClick={() => setConfirmDelete(true)}>
                            <svg className="size-6" fill="none" stroke="currentColor" strokeWidth="1.5"
                                 viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"/>
                            </svg>
                        </button>}
                    {confirmDelete &&
                        <div className="tooltip tooltip-bottom tooltip-open"
                             data-tip="Are you sure? Click again to delete">
                            <button aria-label="Confirm delete" className="btn btn-square btn-error"
                                    onClick={() => deleteSnippet(snippet)}>
                                <svg className="size-6" fill="none" stroke="currentColor" strokeWidth="1.5"
                                     viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                    <path strokeLinecap="round" strokeLinejoin="round"
                                          d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"/>
                                </svg>
                            </button>
                        </div>
                    }
                    <button aria-label="Cancel"
                            className="btn btn-square btn-ghost text-base-content/50 hover:text-base-content"
                            onClick={discardChanges}>
                        <svg className="size-6" fill="none" stroke="currentColor" strokeWidth="1.5"
                             viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M6 18 18 6M6 6l12 12" strokeLinecap="round" strokeLinejoin="round"/>
                        </svg>
                    </button>
                    <button aria-label="Save" className="btn btn-square btn-outline border-0 btn-success"
                            onClick={saveChanges}>
                        <svg className="size-6" fill="none" stroke="currentColor" strokeWidth="1.5"
                             viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path strokeLinecap="round" strokeLinejoin="round" d="m4.5 12.75 6 6 9-13.5"/>
                        </svg>
                    </button>
                </div>
            </div>

            <MilkdownProvider>
                <CrepeEditor content={"# Hello\nHello, world"}/>
            </MilkdownProvider>
        </div>
    );
};