import {SnippetItem} from "./SnippetItem.tsx";
import clsx from "clsx";

export function SnippetList({
                                snippets,
                                editingIDs,
                                startEditing,
                                updateTitle,
                                discardChanges,
                                saveChanges,
                                deleteSnippet,
                                closeSnippet
                            }) {

    // TODO Query snippet content and details

    return (
        <>
            {snippets.map((snippet) => {
                const editing = editingIDs.includes(snippet.id);
                return (
                    <div id={snippet.title} key={snippet.id} className={clsx({
                        "card bg-base-100": true,
                        // "border-t-16 border-warning/30": index === 1,
                    })}>
                        <SnippetItem snippetMetadata={snippet} editing={editing} startEditing={startEditing}
                                     updateTitle={updateTitle}
                                     discardChanges={discardChanges} saveChanges={saveChanges}
                                     deleteSnippet={deleteSnippet}
                                     closeSnippet={closeSnippet}/>
                    </div>)
            })}
        </>
    )
}