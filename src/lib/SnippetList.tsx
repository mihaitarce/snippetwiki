import {SnippetEditor} from "./SnippetEditor.tsx";
import {SnippetViewer} from "./SnippetViewer.tsx";

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
    return (
        <>
            {snippets.map((snippet) => {
                const editing = editingIDs.includes(snippet.id);
                return (
                    <li id={snippet.title} key={snippet.id} className="card bg-base-100">
                        {editing &&
                            <SnippetEditor snippet={snippet} deleteSnippet={deleteSnippet}
                                           updateTitle={updateTitle}
                                           discard={discardChanges} save={saveChanges}/>}
                        {!editing &&
                            <SnippetViewer snippet={snippet} edit={startEditing}
                                           close={closeSnippet}/>}
                    </li>
                )
            })
            }
        </>
    )
}