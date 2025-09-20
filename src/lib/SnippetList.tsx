import {SnippetItem} from "./SnippetItem.tsx";

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
                    <li id={snippet.title} key={snippet.id} className="card bg-base-100">
                        <SnippetItem snippetMetadata={snippet} editing={editing} startEditing={startEditing} updateTitle={updateTitle}
                        discardChanges={discardChanges} saveChanges={saveChanges} deleteSnippet={deleteSnippet}
                        closeSnippet={closeSnippet}/>
                    </li>
                )
            })
            }
        </>
    )
}