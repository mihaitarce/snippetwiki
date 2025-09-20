import {Crepe} from "@milkdown/crepe";
import {Milkdown, MilkdownProvider, useEditor, useInstance} from "@milkdown/react";

import "@milkdown/crepe/theme/common/style.css";
import "@milkdown/crepe/theme/frame.css";
import {useState} from "react";
import {collab, collabServiceCtx} from "@milkdown/plugin-collab";

import * as Y from 'yjs';
import {WebsocketProvider} from "y-websocket";

function CrepeEditor({snippet, content, usersPresent, setUsersPresent}) {
    useEditor((root) => {
        const crepe = new Crepe({
            root,
            featureConfigs: {
                [Crepe.Feature.BlockEdit]: {
                    textGroup: {
                        label: 'Text Blocks',
                        text: {
                            label: 'Normal Text',
                            // icon: customTextIcon,
                        },
                        h1: {
                            label: 'Heading',
                            // icon: customH1Icon,
                        },
                        h2: null,
                        h3: null,
                        h4: null,
                        h5: null,
                        h6: null,
                    },
                }
            }
        });

        const colors = [ // all -400 values
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
        const randomColor = () => colors[Math.floor(Math.random() * colors.length)];

        const roomName = `${snippet.id}`;

        const doc = new Y.Doc();
        const wsProvider = new WebsocketProvider('/api/yjs/', roomName, doc);

        wsProvider.awareness.setLocalStateField('user', {
            name: 'user',
            color: randomColor(),
        });

        wsProvider.awareness.on('change', (e) => {
            setUsersPresent(Array.from(wsProvider.awareness.getStates().values())
                .filter(state => state !== wsProvider.awareness.getLocalState())
                .map(state => state.user))
        })

        crepe.editor.use(collab).create().then((editor) => {
            editor.action((ctx) => {
                const collabService = ctx.get(collabServiceCtx);

                collabService
                    // bind doc and awareness
                    .bindDoc(doc)
                    .setAwareness(wsProvider.awareness);

                wsProvider.once("synced", async (isSynced: boolean) => {
                    if (isSynced) {
                        if (content) {
                            collabService.applyTemplate(content);
                        }
                        collabService.connect();
                    }
                });
            })
        });

        return crepe;
    });

    return (<div className="relative textarea z-1 w-full min-h-96">
        {usersPresent.length > 0 && <div
            className="absolute top-[-1em] right-[0.5em] z-2 bg-base-100 px-2 flex flex-wrap items-center justify-end gap-1"
            title={`${usersPresent.length} users editing`}>
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth="1.5"
                 stroke="currentColor"
                 className="size-4 text-base-content/50 me-1">
                <path strokeLinecap="round" strokeLinejoin="round"
                      d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z"/>
            </svg>
            {usersPresent.map((user, index) => (
                <div key={index} title={user.name}
                     className="badge" style={{"--badge-color": user.color} as React.CSSProperties}>
                    {user.name.slice(0, 1).toUpperCase()}
                </div>
            ))}
        </div>}

        <Milkdown/>
    </div>);
}


export function SnippetEditor({snippet, deleteSnippet, updateTitle, discard, save}) {
    const [confirmDelete, setConfirmDelete] = useState(false);
    const [usersPresent, setUsersPresent] = useState([])

    function discardChanges() {
        if (confirmDelete) {
            setConfirmDelete(false)
        } else {
            // discard(snippet)
            discard(snippet, usersPresent.length > 0)

            // wsProvider.disconnect()
            // collabService.disconnect()
        }
    }

    function saveChanges() {
        save(snippet, `# Hello\nThe time is ${new Date().toLocaleDateString()}`, usersPresent.length > 0);
        // save(crepe.getMarkdown(), usersPresent.length > 0)

        // wsProvider.disconnect()
        // collabService.disconnect()
    }

    return (
        <div className="card-body">
            <div className="flex flex-wrap items-center justify-between gap-6 mb-3">
                <h1 className="flex-1 font-serif text-3xl min-w-64">
                    <input type="text" className="input input-xl w-full font-serif"
                           value={snippet.draft_title} placeholder={snippet.title}
                           onChange={(e) => updateTitle(snippet, e.target.value)}
                    />
                </h1>
                <div className="flex gap-3">
                    {!confirmDelete &&
                        <button aria-label="Delete" className="btn btn-square btn-outline border-0 btn-error"
                                onClick={() => setConfirmDelete(true)}>
                            <svg className="size-6" fill="none" stroke="currentColor" strokeWidth="1.5"
                                 viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"/>
                            </svg>
                        </button>}
                    {confirmDelete &&
                        <div className="tooltip tooltip-bottom tooltip-open"
                             data-tip="Are you sure? Click again to delete">
                            <button aria-label="Confirm delete" className="btn btn-square btn-error"
                                    onClick={() => deleteSnippet(snippet)}>
                                <svg className="size-6" fill="none" stroke="currentColor" strokeWidth="1.5"
                                     viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                    <path strokeLinecap="round" strokeLinejoin="round"
                                          d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"/>
                                </svg>
                            </button>
                        </div>
                    }
                    <button aria-label="Cancel"
                            className="btn btn-square btn-ghost text-base-content/50 hover:text-base-content"
                            onClick={discardChanges}>
                        <svg className="size-6" fill="none" stroke="currentColor" strokeWidth="1.5"
                             viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M6 18 18 6M6 6l12 12" strokeLinecap="round" strokeLinejoin="round"/>
                        </svg>
                    </button>
                    <button aria-label="Save" className="btn btn-square btn-outline border-0 btn-success"
                            onClick={saveChanges}>
                        <svg className="size-6" fill="none" stroke="currentColor" strokeWidth="1.5"
                             viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path strokeLinecap="round" strokeLinejoin="round" d="m4.5 12.75 6 6 9-13.5"/>
                        </svg>
                    </button>
                </div>
            </div>

            <MilkdownProvider>
                <CrepeEditor snippet={snippet} content={"# Hello\nHello, world"}
                             usersPresent={usersPresent} setUsersPresent={setUsersPresent}/>
            </MilkdownProvider>
        </div>
    );
};