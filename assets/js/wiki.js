import React from "react";
import ReactDOM from "react-dom/client";
import Editor from "../components/Editor";
import Viewer from "../components/Viewer";
import { InternalLink } from "../components/InternalLink";

import NumberFlow from '@number-flow/react';

import '@fontsource-variable/noto-sans';
import '@fontsource-variable/noto-serif';
import '@fontsource-variable/noto-sans-mono';

import * as Y from 'yjs';
import { Socket } from "phoenix";
import { PhoenixChannelProvider } from "./y-phoenix-channel";
import { blocksToYXmlFragment } from "@blocknote/core/yjs";
import { BlockNoteSchema, createHeadingBlockSpec, defaultInlineContentSpecs, defaultBlockSpecs, BlockNoteEditor } from "@blocknote/core";

const {pathPrefix} = window.__APP__

function randomColor() {
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

    return colorList[Math.floor(Math.random() * colorList.length)];
}

export const hooks = {
    Editor: {
        mounted() {
            const id = this.el.dataset.id
            const username = this.el.dataset.username

            const textareaElement = this.el.parentNode.querySelector('textarea')

            const socket = new Socket(pathPrefix + "/socket");
            socket.connect();

            const yDoc = new Y.Doc()
            const provider = new PhoenixChannelProvider(socket, `y_doc_room:${id}`, yDoc)

            // const persistence = new IndexeddbPersistence(docname, ydoc);

            // Load content if there is no content in the collaborative document yet
            provider.once('synced', (isSynced) => {
            if (isSynced) {
                const fragment = yDoc.getXmlFragment("document-store")

                if (textareaElement.value.length > 0 && fragment._length === 0) {
                blocksToYXmlFragment(
                    BlockNoteEditor.create(),
                    JSON.parse(textareaElement.value),
                    fragment
                );
                }
            }
            })

            // Uploads a file to tmpfiles.org and returns the URL to the uploaded file.
            async function uploadFile(file) {
                const body = new FormData();
                body.append("file", file);

                const csrfToken = document
                    .querySelector('meta[name="csrf-token"]')
                    .getAttribute('content')

                body.append('_csrf_token', csrfToken)

                const ret = await fetch(`${pathPrefix}/files/upload`, {
                    method: "POST",
                    body: body,
                });
                return (await ret.json()).data.url
            }

            function resolveFileUrl(url) {
                return new Promise((resolve) => {
                    if (url.startsWith("https://") || url.startsWith("http://")) {
                        resolve(url)
                    } else {
                        resolve(`${pathPrefix}/files/${url}`)
                    }
                }) 
            }

            const options = {
                // trailingBlock: false,
                schema: BlockNoteSchema.create({
                    blockSpecs: {
                        heading: createHeadingBlockSpec({
                            // Disables toggleable headings.
                            allowToggleHeadings: false,
                            // Sets the allowed heading levels.
                            levels: [1],
                        }),
                        paragraph: defaultBlockSpecs.paragraph,
                        quote: defaultBlockSpecs.quote,
                        numberedListItem: defaultBlockSpecs.numberedListItem,
                        bulletListItem: defaultBlockSpecs.bulletListItem,
                        codeBlock: defaultBlockSpecs.codeBlock,
                        table: defaultBlockSpecs.table,
                        image: defaultBlockSpecs.image,
                        file: defaultBlockSpecs.file,
                        // audio
                        // video

                    },
                    inlineContentSpecs: {
                        // Adds all default inline content.
                        ...defaultInlineContentSpecs,
                        // text: defaultInlineContentSpecs.text,

                        // Adds the internal tag.
                        InternalLink: InternalLink,
                    }
                    // styleSpecs: { ...
                    //     bold: defaultStyleSpecs.bold,
                }),
                collaboration: {
                    // The Yjs Provider responsible for transporting updates:
                    provider,
                    // Where to store BlockNote data in the Y.Doc:
                    fragment: yDoc.getXmlFragment("document-store"),
                    // Information (name and color) for this user:
                    user: {
                        name: username,
                        color: randomColor()
                    },
                    // When to show user labels on the collaboration cursor. Set by default to
                    // "activity" (show when the cursor moves), but can also be set to "always".
                    showCursorLabels: "activity",
                },
                uploadFile,
                resolveFileUrl
            }

            const root = ReactDOM.createRoot(this.el);
            root.render(<Editor textarea={textareaElement} options={options} />);
        
            this.socket = socket
            this.provider = provider
        },

        destroyed() {
            this.provider.disconnect()
            this.socket.disconnect()
        }
    },

    Viewer: {
        mounted() {
            const id = this.el.dataset.id
            const textareaElement = this.el.parentNode.querySelector('textarea')
            const root = ReactDOM.createRoot(this.el);
            root.render(<Viewer id={id} textarea={textareaElement} />);
        }
    },

    Number: {
        root: null,

        number() {
            return this.el.dataset.number
        },

        updateComponent() {
            this.root.render(<NumberFlow value={this.number()} />)
        },

        mounted() {
            this.root = ReactDOM.createRoot(this.el)
            this.updateComponent()
        },

        updated() {
            this.updateComponent()
        }
    }
}