import {useState} from "react";
import {SnippetEditor} from "./SnippetEditor.tsx";
import {SnippetViewer} from "./SnippetViewer.tsx";

export function SnippetList({snippets, updateSnippet, deleteSnippet, closeSnippet}) {
    const [editingIDs, setEditingIDs] = useState([]);

    function startEditing(snippet) {
        if (!editingIDs.includes(snippet.id)) {
            setEditingIDs([...editingIDs, snippet.id]);
        }
    }

    function stopEditing(snippet) {
        setEditingIDs(editingIDs.filter((id) => id !== snippet.id));
    }

    function cancelEdit(snippet) {
        stopEditing(snippet);
    }

    function saveEdit(snippet) {
        updateSnippet(snippet);
        stopEditing(snippet);
    }

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
                            <SnippetViewer snippet={snippet} edit={startEditing} close={closeSnippet}/>}
                    </li>
                )
            })
            }
        </>
    )
}