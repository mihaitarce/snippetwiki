import {eq, max, useLiveQuery} from "@tanstack/react-db";
import {latestRevisionsCollection, revisionsCollection, snippetsCollection} from "./collection.ts";

import {SnippetEditor} from "./SnippetEditor.tsx";
import {SnippetViewer} from "./SnippetViewer.tsx";

export function SnippetItem({
                                snippetMetadata, editing, startEditing, updateTitle,
                                discardChanges, saveChanges, deleteSnippet, closeSnippet
                            }) {
    const {data: revision, isLoading, isError} = useLiveQuery((q) => q
        .from({revision: revisionsCollection})
        .select(({revision}) => ({
            id: revision.id,
            snippet_id: revision.snippet_id,
            author: revision.author,
            content: revision.content,
            content_type: revision.content_type,
            version: revision.version,
            file: revision.file,
            created: revision.created
        }))
        .where(({revision}) => eq(revision.snippet_id, snippetMetadata.id))
        .orderBy(({revision}) => revision.version, 'desc')
        .limit(1)
    )

if (isLoading) {
    return (<div className="card-body h-64 flex flex-col items-center justify-center text-base-content/50">
        <span className="text-2xl">Loading</span>
        <span className="loading loading-dots loading-xl"></span>
    </div>)
}

if (isError) {
    // TODO show error message
}

if (editing) {
    return (<SnippetEditor snippet={snippetMetadata} deleteSnippet={deleteSnippet}
                           updateTitle={updateTitle}
                           discard={discardChanges} save={saveChanges}/>)
}

return (<SnippetViewer snippet={snippetMetadata}
                       edit={startEditing} close={closeSnippet}/>)
}