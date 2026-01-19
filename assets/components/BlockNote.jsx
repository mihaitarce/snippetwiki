import React, { useEffect } from "react";
import { BlockNoteSchema, createHeadingBlockSpec } from "@blocknote/core";
import { useCreateBlockNote } from "@blocknote/react";
// Or, you can use ariakit, shadcn, etc.
import { BlockNoteView } from "@blocknote/mantine";
// Default styles for the mantine editor
import "@blocknote/mantine/style.css";


export default function BlockNote({ textarea }) {
  const options = {
    trailingBlock: false,
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
  }

  if (textarea) {
    if (textarea.value.length > 0) {
      // Load content from textarea
      options.initialContent = JSON.parse(textarea.value)
    }

    // Update textarea content on form submission
    useEffect(() => {
      textarea.form?.addEventListener('submit', (e) => {
        textarea.value = JSON.stringify(editor.document)
      })
    }, [])
  }

  // Create a new editor instance
  const editor = useCreateBlockNote(options);

  // Render the editor
  if (textarea.form) {
    return (<div className="textarea w-full min-h-42">
        <BlockNoteView editor={editor} />
      </div>)
  } else {
    return (<div className="bn-editor-readonly">
        <BlockNoteView editor={editor} editable={false} />
      </div>)
  }
}