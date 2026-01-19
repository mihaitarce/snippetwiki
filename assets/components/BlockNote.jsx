import React, { useEffect } from "react";
import { BlockNoteSchema, createHeadingBlockSpec } from "@blocknote/core";
import { useCreateBlockNote } from "@blocknote/react";
// Or, you can use ariakit, shadcn, etc.
import { BlockNoteView } from "@blocknote/mantine";
// Default styles for the mantine editor
import "@blocknote/mantine/style.css";

import * as Y from 'yjs';
import { Socket } from "phoenix";
import { PhoenixChannelProvider } from "./y-phoenix-channel";

export default function BlockNote({ id, textarea }) {
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
    })
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

    if (textarea.form) {
      const socket = new Socket("/socket");
      socket.connect();

      const yDoc = new Y.Doc()
      const provider = new PhoenixChannelProvider(
          socket,
          `y_doc_room:${id}`,
          yDoc,
      );
      const awareness = provider.awareness

      // const persistence = new IndexeddbPersistence(docname, ydoc);

      var nameList = [
          'Time','Past','Future','Dev',
          'Fly','Flying','Soar','Soaring','Power','Falling',
          'Fall','Jump','Cliff','Mountain','Rend','Red','Blue',
          'Green','Yellow','Gold','Demon','Demonic','Panda','Cat',
          'Kitty','Kitten','Zero','Memory','Trooper','XX','Bandit',
          'Fear','Light','Glow','Tread','Deep','Deeper','Deepest',
          'Mine','Your','Worst','Enemy','Hostile','Force','Video',
          'Game','Donkey','Mule','Colt','Cult','Cultist','Magnum',
          'Gun','Assault','Recon','Trap','Trapper','Redeem','Code',
          'Script','Writer','Near','Close','Open','Cube','Circle',
          'Geo','Genome','Germ','Spaz','Shot','Echo','Beta','Alpha',
          'Gamma','Omega','Seal','Squid','Money','Cash','Lord','King',
          'Duke','Rest','Fire','Flame','Morrow','Break','Breaker','Numb',
          'Ice','Cold','Rotten','Sick','Sickly','Janitor','Camel','Rooster',
          'Sand','Desert','Dessert','Hurdle','Racer','Eraser','Erase','Big',
          'Small','Short','Tall','Sith','Bounty','Hunter','Cracked','Broken',
          'Sad','Happy','Joy','Joyful','Crimson','Destiny','Deceit','Lies',
          'Lie','Honest','Destined','Bloxxer','Hawk','Eagle','Hawker','Walker',
          'Zombie','Sarge','Capt','Captain','Punch','One','Two','Uno','Slice',
          'Slash','Melt','Melted','Melting','Fell','Wolf','Hound',
          'Legacy','Sharp','Dead','Mew','Chuckle','Bubba','Bubble','Sandwich','Smasher','Extreme','Multi','Universe','Ultimate','Death','Ready','Monkey','Elevator','Wrench','Grease','Head','Theme','Grand','Cool','Kid','Boy','Girl','Vortex','Paradox'
      ];
      const randomName = () => `${nameList[Math.floor( Math.random() * nameList.length )]} ${nameList[Math.floor( Math.random() * nameList.length )]}`;

      const colorList = [ // all -400 values
          '#fb923c', // 'oklch(75% 0.183 55.934)', // orange
          '#facc15', // 'oklch(85.2% 0.199 91.936)', // yellow
          '#a3e635', // 'oklch(84.1% 0.238 128.85)', // lime
          '#34d399', // 'oklch(76.5% 0.177 163.223)', // emerald
          '#22d3ee', // 'oklch(78.9% 0.154 211.53)', // cyan
          '#60a5fa', // 'oklch(70.7% 0.165 254.624)', // blue
          '#a78bfa', // 'oklch(70.2% 0.183 293.541)', // violet
          '#e879f9', // 'oklch(74% 0.238 322.16)', // fuchsia
          '#fb7185', // 'oklch(71.2% 0.194 13.428)' // rose
      ]
      const randomColor = () => colorList[Math.floor(Math.random() * colorList.length)];

      const localUser = {
        name: randomName(),
        color: randomColor()
      }

      options.collaboration = {
        // The Yjs Provider responsible for transporting updates:
        provider,
        // Where to store BlockNote data in the Y.Doc:
        fragment: yDoc.getXmlFragment("document-store"),
        // Information (name and color) for this user:
        user: localUser,
        // When to show user labels on the collaboration cursor. Set by default to
        // "activity" (show when the cursor moves), but can also be set to "always".
        showCursorLabels: "activity",
      }

      // provider.awareness.setLocalStateField('user', localUser)

      // // You can observe when a user updates their awareness information
      // awareness.on('change', changes => {
      //     usersPresent = Array.from(awareness.getStates().values()
      //         .filter(state => state.user !== localUser)
      //         .map(state => state.user))
      // })
    }

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