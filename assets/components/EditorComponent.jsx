import React, { useEffect, useState } from "react"
import { useCreateBlockNote } from "@blocknote/react";
// Or, you can use ariakit, shadcn, etc.
import { BlockNoteView } from "@blocknote/mantine";
// Default styles for the mantine editor
import "@blocknote/mantine/style.css";

function initials(name) {
    const rgx = new RegExp(/(\p{L}{1})\p{L}+/, 'gu');

    const initials = [...name.matchAll(rgx)] || [];

    return (
    (initials.shift()?.[1] || '') + (initials.pop()?.[1] || '')
    ).toUpperCase();
}


export default function EditorComponent({ options, provider, localUser, textarea }) {
    const [usersPresent, setUsersPresent] = useState([])

    useEffect(() => {
        // You can observe when a user updates their awareness information
        const awareness = provider.awareness

        awareness.on('change', changes => {
            setUsersPresent(Array
                .from(awareness.getStates().values())
                .filter(state => state.user !== localUser)
                .map(state => state.user));
        })

        // Update textarea content on form submission
        textarea.form.addEventListener('submit', (e) => {
          textarea.value = JSON.stringify(editor.document)
        })
    }, [])

    const editor = useCreateBlockNote(options);

    return (<div className="textarea w-full min-h-42 relative">
        <div className="flex gap-1 bg-base-100 rounded px-1 absolute bottom-[-10px] right-2">
            You:
            <div style={{backgroundColor: localUser.color}}>{initials(localUser.name)}</div>
            Others ({usersPresent.length}):
            {usersPresent.map((u) => <div key={u.name} style={{backgroundColor: u.color}}>{initials(u.name)}</div>)}
        </div>

        <BlockNoteView editor={editor} />
    </div>)
}