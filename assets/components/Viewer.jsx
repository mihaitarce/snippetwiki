import React from "react"
import { InternalLink } from "./InternalLink";
import { useCreateBlockNote } from "@blocknote/react";
import { BlockNoteSchema, createHeadingBlockSpec, defaultInlineContentSpecs } from "@blocknote/core";
// Or, you can use ariakit, shadcn, etc.
import { BlockNoteView } from "@blocknote/mantine";
// Default styles for the mantine editor
import "@blocknote/mantine/style.css";

const {pathPrefix} = window.__APP__


export default function Viewer({ id, textarea }) {
    const options = {
        // trailingBlock: false,
        schema: BlockNoteSchema.create().extend({
            inlineContentSpecs: {
                // Adds all default inline content.
                ...defaultInlineContentSpecs,
                // Adds the internal link tag.
                InternalLink: InternalLink,
            },
        }),
        resolveFileUrl: (url) => {
            return new Promise((resolve) => {
                if (url.startsWith("https://") || url.startsWith("http://")) {
                    resolve(url)
                } else {
                    resolve(`${pathPrefix}/files/${url}`)
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