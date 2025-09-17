import {SnippetEditor} from "./SnippetEditor.tsx";
import {SnippetViewer} from "./SnippetViewer.tsx";

export function SnippetList({
                                snippets,
                                editingIDs,
                                startEditing,
                                cancelEdit,
                                saveEdit,
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
                            <SnippetEditor snippet={snippet} deleteSnippet={deleteSnippet} discard={cancelEdit}
                                           save={saveEdit}/>}
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