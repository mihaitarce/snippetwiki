import React, { useEffect, useState } from "react"
import { useCreateBlockNote } from "@blocknote/react";
// Or, you can use ariakit, shadcn, etc.
import { BlockNoteView } from "@blocknote/mantine";
// Default styles for the mantine editor
import "@blocknote/mantine/style.css";

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

    return (<div>
        {usersPresent.length}:
        {usersPresent.map((u) => <div key={u.name} style={{backgroundColor: u.color}}>{u.name}</div>)}

        <BlockNoteView editor={editor} />
    </div>)
}