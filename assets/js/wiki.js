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

function safeDecodeHashTitle(rawHashTitle) {
    try {
        return decodeURIComponent(rawHashTitle)
    } catch {
        try {
            const repaired = rawHashTitle.replace(/%(?![0-9A-Fa-f]{2})/g, "%25")
            return decodeURIComponent(repaired)
        } catch {
            return rawHashTitle
        }
    }
}

function normalizeHashTitle(rawTitle) {
    const withoutPrefix = rawTitle.replace(/^Notes:\s*/i, "")
    const withoutSuffix = withoutPrefix
        .replace(/\s*\(#\d+\)\s*$/, "")
        .replace(/\s*\(#\d+.*$/, "")
    const normalized = withoutSuffix.trim()

    return normalized || rawTitle.trim()
}

export const hooks = {
    WikiHashOpen: {
        // Also persists the set of open snippet cards so a page reload
        // restores the reading session instead of dropping it.
        persistOpenSnippets() {
            const ids = Array
                .from(document.querySelectorAll('#article-stream > div[id^="snippet-"]'))
                .map(el => parseInt(el.id.replace("snippet-", ""), 10))
                .filter(Number.isInteger)

            try {
                localStorage.setItem("wiki:openSnippets", JSON.stringify(ids))
            } catch {
                // Storage full or unavailable; persistence is best-effort.
            }
        },

        restoreOpenSnippets() {
            let ids
            try {
                ids = JSON.parse(localStorage.getItem("wiki:openSnippets") || "[]")
            } catch {
                ids = []
            }

            // Always report, even an empty list: the server only opens the
            // Welcome fallback when it knows there is no session to restore.
            this.pushEvent("restore_open", {ids: Array.isArray(ids) ? ids : []})
        },

        mounted() {
            this.clearHashFromUrl = () => {
                if (!window.location.hash) {
                    return
                }

                const cleanUrl = `${window.location.pathname}${window.location.search}`
                window.history.replaceState(null, "", cleanUrl)
            }

            this.openFromHash = () => {
                const rawHash = window.location.hash
                if (!rawHash || rawHash.length <= 1) {
                    return
                }

                let title
                try {
                    title = safeDecodeHashTitle(rawHash.slice(1)).trim()
                } catch {
                    return
                }

                if (!title) {
                    return
                }

                title = normalizeHashTitle(title)

                const bag = this.el.dataset.defaultBag
                if (!bag) {
                    return
                }

                this.pushEvent("open_initial", {value: {title, bag}})
                this.clearHashFromUrl()
            }

            this.openFromHash()
            window.addEventListener("hashchange", this.openFromHash)

            this.restoreOpenSnippets()

            const stream = document.getElementById("article-stream")
            if (stream) {
                this.openObserver = new MutationObserver(() => this.persistOpenSnippets())
                this.openObserver.observe(stream, {childList: true})
            }
        },

        destroyed() {
            window.removeEventListener("hashchange", this.openFromHash)
            this.openObserver?.disconnect()
        }
    },

    // Link button on article cards: copies the absolute permalink and briefly
    // shows a "Link copied" tooltip as feedback.
    CopyPermalink: {
        mounted() {
            this.onClick = async () => {
                const url = `${window.location.origin}${this.el.dataset.url}`

                try {
                    await navigator.clipboard.writeText(url)
                } catch {
                    // Clipboard API unavailable (e.g. non-secure context):
                    // fall back to a temporary input element.
                    const input = document.createElement("input")
                    input.value = url
                    document.body.appendChild(input)
                    input.select()
                    document.execCommand("copy")
                    input.remove()
                }

                this.el.classList.add("tooltip", "tooltip-open")
                clearTimeout(this.resetTimer)
                this.resetTimer = setTimeout(() => {
                    this.el.classList.remove("tooltip", "tooltip-open")
                }, 1500)
            }

            this.el.addEventListener("click", this.onClick)
        },

        destroyed() {
            clearTimeout(this.resetTimer)
            this.el.removeEventListener("click", this.onClick)
        }
    },

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
    },

    // Drag handle that resizes an adjacent panel by driving a CSS variable
    // on <html> (survives LiveView patches). Width persists per panel in
    // localStorage; double-click resets to the default.
    PanelResize: {
        mounted() {
            const panel = this.el.dataset.panel
            const targetId = this.el.dataset.target
            const min = parseInt(this.el.dataset.min, 10)
            const max = parseInt(this.el.dataset.max, 10)
            const dir = this.el.dataset.grow === "left" ? -1 : 1
            const varName = `--${panel}-w`
            const storageKey = `wiki:${panel}Width`

            const saved = parseInt(localStorage.getItem(storageKey), 10)

            if (Number.isInteger(saved)) {
                document.documentElement.style.setProperty(varName, saved + "px")
            }

            this.onDblClick = () => {
                document.documentElement.style.removeProperty(varName)
                localStorage.removeItem(storageKey)
            }

            this.onPointerDown = (e) => {
                e.preventDefault()

                const target = document.getElementById(targetId)

                if (!target) {
                    return
                }

                const startX = e.clientX
                const startWidth = target.getBoundingClientRect().width
                const iframe = document.getElementById("wikirag-embed")
                let width = startWidth

                const move = (ev) => {
                    width = Math.min(max, Math.max(min, startWidth + dir * (ev.clientX - startX)))
                    document.documentElement.style.setProperty(varName, width + "px")
                }

                const up = () => {
                    window.removeEventListener("pointermove", move)
                    window.removeEventListener("pointerup", up)
                    document.body.style.userSelect = ""
                    document.body.style.cursor = ""
                    if (iframe) iframe.style.pointerEvents = ""

                    try {
                        localStorage.setItem(storageKey, String(Math.round(width)))
                    } catch {
                        // Persistence is best-effort.
                    }
                }

                window.addEventListener("pointermove", move)
                window.addEventListener("pointerup", up)
                document.body.style.userSelect = "none"
                document.body.style.cursor = "col-resize"
                if (iframe) iframe.style.pointerEvents = "none"
            }

            this.el.addEventListener("pointerdown", this.onPointerDown)
            this.el.addEventListener("dblclick", this.onDblClick)
        },

        destroyed() {
            this.el.removeEventListener("pointerdown", this.onPointerDown)
            this.el.removeEventListener("dblclick", this.onDblClick)
        }
    },

    WikiRagEmbed: {
        mounted() {
            this.onMessage = (event) => {
                const {action, title, bag} = event.data ?? {}
                if (action !== "openSnippet" || typeof title !== "string" || !title || typeof bag !== "string" || !bag) {
                    return
                }

                const iframe = this.el.querySelector("#wikirag-embed")
                if (iframe?.src) {
                    try {
                        if (event.origin !== new URL(iframe.src).origin) {
                            return
                        }
                    } catch {
                        return
                    }
                }

                this.pushEvent("open_initial", {value: {title, bag}})
            }

            window.addEventListener("message", this.onMessage)
        },

        destroyed() {
            window.removeEventListener("message", this.onMessage)
        }
    }
}