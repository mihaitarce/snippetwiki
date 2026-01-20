import React from "react"
import { useCreateBlockNote } from "@blocknote/react";
import { BlockNoteSchema, createHeadingBlockSpec } from "@blocknote/core";
// Or, you can use ariakit, shadcn, etc.
import { BlockNoteView } from "@blocknote/mantine";
// Default styles for the mantine editor
import "@blocknote/mantine/style.css";

export default function Viewer({ id, textarea }) {
    const options = {
        // trailingBlock: false,
        schema: BlockNoteSchema.create().extend({
            blockSpecs: {
            heading: createHeadingBlockSpec({
                // Disables toggleable headings.
                allowToggleHeadings: false,
                // Sets the allowed heading levels.
                levels: [1],
            }),
            },
        }),
        resolveFileUrl: (url) => {
            return new Promise((resolve) => {
                if (url.startsWith("https://")) {
                    resolve(url)
                } else {
                    resolve(`/files/${url}`)
                }
            }) 
        }
    }

    if (textarea?.value.length > 0) {
        options.initialContent = JSON.parse(textarea.value);
    }

    const editor = useCreateBlockNote(options);

    return (<div className="bn-editor-readonly">
        <BlockNoteView editor={editor} editable={false} />
    </div>)
}