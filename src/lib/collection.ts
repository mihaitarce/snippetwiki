import {createCollection} from '@tanstack/react-db'
import {electricCollectionOptions} from "@tanstack/electric-db-collection";

export const scoresCollection = createCollection(
    electricCollectionOptions({
        shapeOptions: {
            url: `${window.location}api/v1/shape`,
            params: {
                table: 'scores'
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


const BASE_URL = "http://localhost:5000";

function createSnippet(snippet) {
    return fetch(`${BASE_URL}/snippets/`, {
        method: "POST",
        body: JSON.stringify(snippet)
    }).then(res => res.json())
}

function updateSnippet(snippet) {
    return fetch(`${BASE_URL}/snippets/${snippet.id}`, {
        method: "PUT",
        body: JSON.stringify(snippet)
    }).then(res => res.json())
}

function deleteSnippet(snippet) {
    return fetch(`${BASE_URL}/snippets/${snippet.id}`, {
        method: "DELETE"
    }).then(res => res.json())
}
