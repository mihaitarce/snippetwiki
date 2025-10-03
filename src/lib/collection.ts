import {createCollection} from '@tanstack/react-db'
import {electricCollectionOptions} from "@tanstack/electric-db-collection";

// const API_URL = "http://localhost:5000";
const API_URL = window.location.href.split('#')[0];

export const snippetsCollection = createCollection(
    electricCollectionOptions({
        shapeOptions: {
            url: `${API_URL}api/electric/v1/shape`,
            params: {
                table: 'snippets'
            }
        },
        getKey: (item) => item.id,

        onInsert: async ({transaction}) => {
            const newItem = transaction.mutations[0].modified;
            const response = await createSnippet(newItem);
            return {txid: response.txid};
        },

        onUpdate: async ({transaction}) => {
            const updatedItem = transaction.mutations[0].modified;
            const response = await updateSnippet(updatedItem);
            return {txid: response.txid};
        },

        onDelete: async ({transaction}) => {
            const deletedItem = transaction.mutations[0].modified;
            const response = await deleteSnippet(deletedItem);
            return {txid: response.txid};
        }
    })
);


export const latestRevisionsCollection = createCollection(
    electricCollectionOptions({
        shapeOptions: {
            url: `${API_URL}api/electric/v1/shape`,
            params: {
                table: 'revisions',
                columns: ['id', 'snippet_id', 'author', 'content_type', 'version', 'file', 'created']
            }
        },
        getKey: (item) => item.id,
    })
);

export function revisionCollectionOne(snippet_id) {
    const params = {
        table: 'revisions',
    }

    if (snippet_id) {
        params.where = 'id = $1';
        params.params = [ snippet_id ]
    } else {
        params.where = 'FALSE'
    }

    return createCollection(
        electricCollectionOptions({
            shapeOptions: {
                url: `${API_URL}api/electric/v1/shape`,
                params: params
            },
            getKey: (item) => item.id,

            onInsert: async ({transaction}) => {
                const newItem = transaction.mutations[0].modified;
                const response = await createRevision(newItem.snippet_id, newItem);
                return {txid: response.txid};
            },
        })
    );
}

export const revisionsCollection = createCollection(
    electricCollectionOptions({
        shapeOptions: {
            url: `${API_URL}api/electric/v1/shape`,
            params: {
                table: 'revisions',
                columns: ['id', 'snippet_id', 'author', 'content', 'content_type', 'version', 'file', 'created']
            }
        },
        getKey: (item) => item.id,

        onInsert: async ({transaction}) => {
            const newItem = transaction.mutations[0].modified;
            const response = await createRevision(newItem.snippet_id, newItem);
            return {txid: response.txid};
        },
    })
);



function createSnippet(snippet) {
    return fetch(`${API_URL}api/v1/snippets/`, {
        method: "POST",
        body: JSON.stringify(snippet)
    }).then(res => res.json())
}

function createRevision(snippet_id, revision) {
    return fetch(`${API_URL}api/v1/snippets/${snippet_id}/revisions/`, {
        method: "POST",
        body: JSON.stringify(revision)
    }).then(res => res.json())
}


function updateSnippet(snippet) {
    return fetch(`${API_URL}api/v1/snippets/${snippet.id}`, {
        method: "PUT",
        body: JSON.stringify(snippet)
    }).then(res => res.json())
}

function deleteSnippet(snippet) {
    return fetch(`${API_URL}api/v1/snippets/${snippet.id}`, {
        method: "DELETE"
    }).then(res => res.json())
}