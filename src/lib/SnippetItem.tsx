import {eq, max, useLiveQuery} from "@tanstack/react-db";
import {
    snippetsCollection,
    revisionCollectionOne
} from "./collection.ts";

import {SnippetEditor} from "./SnippetEditor.tsx";
import {SnippetViewer} from "./SnippetViewer.tsx";

export function SnippetItem({
                                snippetMetadata, editing, startEditing, updateTitle,
                                discardChanges, saveChanges, deleteSnippet, closeSnippet
                            }) {

    const {data: snippet, isLoading, isError} = useLiveQuery((q) => {
        return q.from({snippet: snippetsCollection})
            .join({revision: revisionCollectionOne(snippetMetadata.revision__id)}, ({snippet, revision}) =>
                eq(snippet.id, revision.snippet_id)
            )
            .select(({snippet, revision}) => {
                return ({
                    id: snippet.id,
                    title: snippet.title,
                    modified: snippet.modified,
                    draft_title: snippet.draft_title,
                    draft_created: snippet.draft_created,
                    revision__id: revision.id,
                    revision__author: revision.author,
                    revision__content: revision.content,
                    revision__content_type: revision.content_type,
                    revision__version: revision.version,
                    revision__file: revision.file,
                    revision__created: revision.created,
                })
            })
            .where(({snippet}) => eq(snippet.id, snippetMetadata.id))
    });

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
        return (<SnippetEditor snippet={snippet[0]} deleteSnippet={deleteSnippet}
                               updateTitle={updateTitle}
                               discard={discardChanges} save={saveChanges}/>)
    }

    return (<>
        <SnippetViewer snippet={snippet[0]}
                           edit={startEditing} close={closeSnippet}/>
        </>)
}