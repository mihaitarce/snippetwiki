import './App.css'

import {useLiveQuery, eq, max, and} from "@tanstack/react-db";
import {SnippetList} from "./lib/SnippetList.tsx";
import {Search} from "./lib/Search"
import {ConceptMap} from "./lib/ConceptMap.tsx";
import {latestRevisionsCollection, snippetsCollection} from "./lib/collection.ts";
import {useMemo, useRef, useState} from "react";
import {OpenSnippets, RecentSnippets} from "./lib/SnippetUtils.tsx";
import {AddButton} from "./lib/AddButton.tsx";
import clsx from "clsx";
import {Import} from "./lib/Import.tsx";
import {useAutoAnimate} from "@formkit/auto-animate/react";
import {DraftList} from "./lib/DraftList.tsx";
import {Sidebar} from "./lib/Sidebar.tsx";

enum Tabs {
    Open,
    Recent,
    Sidebar,
    Map
}

function App() {
    const {data: snippets} = useLiveQuery((q) => {
        const latestRevisions = q
            .from({revision: latestRevisionsCollection})
            .groupBy(({revision}) => [revision.snippet_id])
            .select(({revision}) => ({
                snippet_id: revision.snippet_id,
                version: max(revision.version)
            }))
            .orderBy(({revision}) => revision.version, 'desc')

        const revisionsMetadata = q
            .from({revision: latestRevisionsCollection})
            .select(({revision}) => ({
                id: revision.id,
                snippet_id: revision.snippet_id,
                author: revision.author,
                content_type: revision.content_type,
                version: revision.version,
                file: revision.file,
                created: revision.created
            })).orderBy(({revision}) => revision.version, 'desc')

        return q.from({snippet: snippetsCollection})
            .join({latestRevision: latestRevisions}, ({snippet, latestRevision}) =>
                eq(snippet.id, latestRevision.snippet_id)
            )
            .join({revisionMetadata: revisionsMetadata}, ({latestRevision, revisionMetadata}) =>
                eq(latestRevision.version, revisionMetadata.version)
            )
            .select(({snippet, revisionMetadata}) => {
                return ({
                    id: snippet.id,
                    title: snippet.title,
                    modified: snippet.modified,
                    draft_title: snippet.draft_title,
                    draft_created: snippet.draft_created,
                    revision__id: revisionMetadata.id,
                    revision__author: revisionMetadata.author,
                    revision__version: revisionMetadata.version,
                })
            })
            .orderBy(({snippet}) => snippet.modified, 'desc')
    });

    const [openNames, setOpenNames] = useState(['n2U1NxoOVAL', 'zq0fi7bwG4vHvCo0hC']);

    const openSnippets = useMemo(() => {
        if (snippets === undefined) {
            return []
        } else {
            return openNames.map(name => snippets.find(snippet => snippet.title === name))
                .filter(snippet => snippet !== undefined);
        }
    }, [snippets, openNames]);

    const draftSnippets = useMemo(() => {
        if (snippets === undefined) {
            return []
        } else {
            return snippets.filter(snippet => snippet.draft_created && !openSnippets.includes(snippet))
        }
    }, [snippets, openSnippets]);

    function createSnippet() {
        const availableTitleBase = 'New article'
        let availableTitle = undefined

        let index = 1
        while (true) {
            const candidateTitle = `${availableTitleBase} ${index}`;
            if (!snippets.find(article => article.title === candidateTitle)) {
                availableTitle = candidateTitle;
                break;
            }

            index++;
        }

        const newID = crypto.randomUUID();
        const newSnippet = {
            id: newID,
            title: availableTitle,
            // tags: [],
            modified: new Date().toISOString(),
            draft_title: '',
            draft_created: new Date().toISOString(),
        }
        snippetsCollection.insert(newSnippet);

        //     const inserted = await z.current.query.article.where('id', newID).one();
        //     console.log(inserted)
        openSnippet(newSnippet, true)
    }

    function openSnippet(snippet, editing = false) {
        if (!openNames.includes(snippet.title)) {
            setOpenNames([snippet.title, ...openNames]);
        }

        if (editing) {
            startEditing(snippet)
        }

        setTimeout(() => scrollTo(snippet))
    }

    function scrollTo(snippet) {
        document.getElementById(snippet.title)?.scrollIntoView({behavior: 'smooth'})
    }

    function closeSnippet(snippet) {
        stopEditing(snippet)
        setOpenNames(openNames.filter((name) => name !== snippet.title));
    }

    function closeAllSnippets() {
        setEditingIDs([]);
        setOpenNames([]);
    }

    const [editingIDs, setEditingIDs] = useState([]);

    function startEditing(snippet) {
        if (!snippet.draft_created) {
            snippetsCollection.update(snippet.id, (draft) => {
                draft.draft_title = snippet.title;
                draft.draft_created = new Date();
            })
        }

        if (!editingIDs.includes(snippet.id)) {
            setEditingIDs([...editingIDs, snippet.id]);
        }
    }

    function stopEditing(snippet) {
        setEditingIDs(editingIDs.filter((id) => id !== snippet.id));
    }

    function updateTitle(snippet, newTitle) {
        snippetsCollection.update(snippet.id, (draft) => {
            draft.draft_title = newTitle;
        })
    }

    function discardChanges(snippet, usersPresent: boolean = false) {
        if (!usersPresent) {
            snippetsCollection.update(snippet.id, (draft) => {
                draft.draft_title = null;
                draft.draft_created = null;
            })
        }
        stopEditing(snippet);
    }

    function saveChanges(snippet, content, usersPresent: boolean = false) {
        snippetsCollection.update(snippet.id, (draft) => {
            draft.title = snippet.draft_title ? snippet.draft_title : snippet.title;
            draft.modified = new Date().toISOString();

            if (!usersPresent) {
                console.log("No users present");
                draft.draft_title = null;
                draft.draft_created = null;
            }
        })

        // TODO should be in the same transaction
        // _client.insert('revisions', {
        //     article_id: articleMetadata.id,
        //     revision: data.result.latest_revision ? (data.result.latest_revision.revision + 1) : 1,
        //     author: 'mihai',
        //     content: content,
        // })

        stopEditing(snippet);
    }

    function deleteSnippet(snippet) {
        snippetsCollection.delete(snippet.id)
        closeSnippet(snippet)
    }

    const [importFiles, setImportFiles] = useState([]);

    function addImportFiles(files) {
        const addedFiles = []
        for (const file of files) {
            console.log(file, importFiles);
            if (!importFiles.find((f: File) =>
                f.name === file.name && f.size === file.size && f.type === file.type)) {
                addedFiles.push(file);
            }
        }
        if (addedFiles.length > 0) {
            setImportFiles([...importFiles, ...addedFiles]);
        }
    }

    const [isDraggingOver, setIsDraggingOver] = useState(false);
    const dragCounter = useRef(0);

    function handleDragEnter(e: React.DragEvent<HTMLDivElement>) {
        if (e.dataTransfer?.types.includes('Files')) {
            dragCounter.current = dragCounter.current + 1;
            setIsDraggingOver(true);
        }
    }

    function handleDragLeave(e: React.DragEvent<HTMLDivElement>) {
        if (e.dataTransfer?.types.includes('Files')) {
            dragCounter.current = dragCounter.current - 1;
            if (dragCounter.current === 0) {
                setIsDraggingOver(false);
            }
        }
    }

    function handleDragOver(e: React.DragEvent<HTMLDivElement>) {
        e.preventDefault();
    }

    function handleDrop(e: React.DragEvent<HTMLDivElement>) {
        e.preventDefault();
        dragCounter.current = 0;
        setIsDraggingOver(false);

        if (e.dataTransfer?.types.includes('Files')) {
            addImportFiles(e.dataTransfer.files);
        }
    }

    const [parent, enableAnimations] = useAutoAnimate()

    const [selectedTab, setSelectedTab] = useState(Tabs.Recent)

    return (<>
        <div role="main" className={clsx({
            "flex flex-col items-center xl:items-start xl:flex-row h-full": true,
            "outline-16 outline-success": isDraggingOver,
        })}
             onDragEnter={handleDragEnter}
             onDragLeave={handleDragLeave}
             onDragOver={handleDragOver}
             onDrop={handleDrop}>
            <div className="flex flex-col xl:h-svh xl:overflow-y-scroll xl:overscroll-none xl:w-[calc(65ch+5rem)]">
                <div className="flex justify-between gap-12 px-4 py-2 sticky top-0 z-1 bg-base-300">
                    <div className="flex items-center gap-3 ps-2">
                        <img src="/logo.svg" alt="snippetwiki" className="h-8"/>
                        <AddButton addSnippet={createSnippet} addImportFiles={addImportFiles}/>
                        {/*<div className="inline-grid *:[grid-area:1/1]">*/}
                        {/*    <div className="status status-lg status-error animate-ping"></div>*/}
                        {/*    <div className="status status-lg status-error"></div>*/}
                        {/*</div>*/}
                    </div>

                    <Search snippets={snippets} openSnippet={openSnippet}/>
                </div>

                <div className="flex flex-col gap-4 p-4">
                    {importFiles.length > 0 &&
                        <Import files={importFiles} snippets={snippets} cancelImport={() => setImportFiles([])}/>}

                    {openSnippets.length > 0 &&
                        <SnippetList snippets={openSnippets} editingIDs={editingIDs}
                                     closeSnippet={closeSnippet} updateTitle={updateTitle}
                                     startEditing={startEditing} discardChanges={discardChanges} saveChanges={saveChanges}
                                     deleteSnippet={deleteSnippet}/>}

                    {!importFiles.length && !openSnippets.length && <div className="card p-6">
                        <div className="mx-auto py-12 mt-6 text-2xl flex flex-col items-center gap-12">
                            <img src="/logo.svg" alt="" className="h-[25vh] grayscale opacity-10"/>
                            <div className="text-base-content/30">No open snippets</div>
                        </div>
                    </div>}
                </div>
            </div>
            <div className="flex-1 h-svh hidden xl:block">
                {/*<div className="filter justify-end absolute right-4">*/}
                {/*    <input className="btn btn-sm btn-ghost filter-reset" type="radio" name="bag"*/}
                {/*           aria-label="All"/>*/}
                {/*    <input className="btn btn-sm" type="radio" name="bag" aria-label="HKU"/>*/}
                {/*    <input className="btn btn-sm" type="radio" name="bag" aria-label="Dentistry"/>*/}
                {/*    <input className="btn btn-sm btn-soft btn-warning" type="radio" name="bag"*/}
                {/*           aria-label="Journal"/>*/}
                {/*</div>*/}

                <div className="tabs tabs-box h-svh rounded-none p-4">
                    <input type="radio" name="tabs" className="tab" aria-label="Sidebar"
                           checked={selectedTab === Tabs.Sidebar} onChange={() => setSelectedTab(Tabs.Sidebar)}/>
                    <div className="tab-content pt-3 overflow-y-scroll overscroll-none">
                        <Sidebar/>
                    </div>

                    <input type="radio" name="tabs" className="tab" aria-label="Recent"
                           checked={selectedTab === Tabs.Recent} onChange={() => setSelectedTab(Tabs.Recent)}/>
                    <div className="tab-content p-3">
                        Recent
                        <RecentSnippets snippets={snippets} openSnippets={openSnippets}
                                        openSnippet={openSnippet} closeSnippet={closeSnippet}/>
                    </div>

                    <input type="radio" name="tabs" className="tab" aria-label="Open"
                           checked={selectedTab === Tabs.Open} onChange={() => setSelectedTab(Tabs.Open)}/>
                    <div className="tab-content p-3">
                        Open
                        <OpenSnippets snippets={openSnippets}
                                      openSnippet={openSnippet} closeSnippet={closeSnippet}
                                      closeAllSnippets={closeAllSnippets}/>
                    </div>

                    <input type="radio" name="tabs" className="tab" aria-label="Map"
                           checked={selectedTab === Tabs.Map} onChange={() => setSelectedTab(Tabs.Map)}/>
                    <div className="tab-content pt-3">
                        {/*{selectedTab === Tabs.Map && <Map/>}*/}
                        {snippets.length > 1 && <ConceptMap snippets={snippets}/>}
                    </div>
                </div>
            </div>
        </div>

        <DraftList drafts={draftSnippets} openSnippet={openSnippet}/>
    </>)
}

export default App
