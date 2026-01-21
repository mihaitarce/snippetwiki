import React, { useEffect, useState } from "react";

import { SuggestionMenuController, useCreateBlockNote } from "@blocknote/react";
// Or, you can use ariakit, shadcn, etc.
import { BlockNoteView } from "@blocknote/mantine";
// Default styles for the mantine editor
import "@blocknote/mantine/style.css";

import { filterSuggestionItems } from "@blocknote/core/extensions";


function initials(name) {
    const rgx = new RegExp(/(\p{L}{1})\p{L}+/, 'gu');

    const initials = [...name.matchAll(rgx)] || [];

    return (
    (initials.shift()?.[1] || '') + (initials.pop()?.[1] || '')
    ).toUpperCase();
}


async function getInternalLinkMenuItems(editor) {
  results = await fetch('/api/snippets')
  json = await results.json()

  return json.data.snippets.map((snippet) => ({
    title: snippet.title,
    onItemClick: () => {
      editor.insertInlineContent([
        {
          type: "InternalLink",
          props: snippet,
        },
        "", // add a space after the link?
      ]);
    },
  }));
}

export default function Editor({ textarea, options }) {
  const [usersPresent, setUsersPresent] = useState([])

  useEffect(() => {
      // You can observe when a user updates their awareness information
      const awareness = options.collaboration.provider.awareness

      awareness.on('change', changes => {
          setUsersPresent(Array
              .from(awareness.getStates().values())
              .filter(state => state.user !== options.collaboration.user)
              .map(state => state.user));
      })

      // Update textarea content on form submission
      textarea.form.addEventListener('submit', (e) => {
        textarea.value = JSON.stringify(editor.document)
      })
  }, [])

  const editor = useCreateBlockNote(options);

  // Render the editor
  return (<div className="textarea w-full min-h-42 relative mt-4">
      {usersPresent.length > 0 && <div className="flex items-center gap-1 bg-base-100 rounded h-6 px-1 absolute top-[-13px] right-2" style={{zIndex: 2}}>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor" className="size-[1.2em]">
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z" />
          </svg>
          {usersPresent.map((u) => <div key={u.name} className="badge" style={{backgroundColor: u.color}}>{initials(u.name)}</div>)}
      </div>}

      <BlockNoteView editor={editor}>
        {/* Adds an internal link menu which opens with the "[" key */}
        <SuggestionMenuController
          triggerCharacter={"["}
          getItems={async (query) =>
            // Gets the internal link menu items
            filterSuggestionItems(await getInternalLinkMenuItems(editor), query)
          }
        />
      </BlockNoteView>
  </div>)
}