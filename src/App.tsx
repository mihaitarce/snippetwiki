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

    function addSnippet() {
        const newSnippet = {
            id: crypto.randomUUID(),
            title: 'Mihai',
            modified: new Date().toISOString()
        }
        snippetsCollection.insert(newSnippet);
        openSnippet(newSnippet)
    }

    function deleteSnippet(snippet) {
        snippetsCollection.delete(snippet.id)
        closeSnippet(snippet)
    }

    function openSnippet(snippet, editing = false) {
        if (!openNames.includes(snippet.title)) {
            setOpenNames([snippet.title, ...openNames]);
        }

        if (editing) {

        }

        setTimeout(() => scrollTo(snippet))
    }

    function scrollTo(snippet) {
        document.getElementById(snippet.title)?.scrollIntoView({behavior: 'smooth'})
    }

    function closeSnippet(snippet) {
        setOpenNames(openNames.filter((name) => name !== snippet.title));
    }

    const [editingIDs, setEditingIDs] = useState([]);

    function startEditing(snippet) {
        if (!editingIDs.includes(snippet.id)) {
            setEditingIDs([...editingIDs, snippet.id]);
        }
    }

    function stopEditing(snippet) {
        setEditingIDs(editingIDs.filter((id) => id !== snippet.id));
    }

    function cancelEdit(snippet) {
        stopEditing(snippet);
    }

    function saveEdit(snippet) {
        snippetsCollection.update(snippet.id, (draft) => {
            draft.modified = new Date().toISOString();
        })

        stopEditing(snippet);
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

    return (
        <div className="flex px-4 gap-6 flex-col items-center lg:items-start lg:flex-row" role="main">
            <div
                ref={parent}
                className={clsx({
                    "flex-none order-2 lg:order-1 mx-auto w-full max-w-[calc(65ch+3rem)] lg:w-[calc(65ch+3rem)] my-4": true,
                    "flex flex-col gap-6": true,
                    "outline-16 outline-success": isDraggingOver,
                })}
                onDragEnter={handleDragEnter}
                onDragLeave={handleDragLeave}
                onDragOver={handleDragOver}
                onDrop={handleDrop}>

                {importFiles.length > 0 &&
                    <Import files={importFiles} snippets={snippets} cancelImport={() => setImportFiles([])}/>}

                {openSnippets.length > 0 &&
                    <SnippetList snippets={openSnippets} editingIDs={editingIDs}
                                 closeSnippet={closeSnippet}
                                 startEditing={startEditing} cancelEdit={cancelEdit} saveEdit={saveEdit}
                                 deleteSnippet={deleteSnippet}/>}

                {!importFiles.length && !openSnippets.length && <div className="card p-6">
                    <div className="mx-auto py-12 mt-6 text-2xl flex flex-col items-center gap-12">
                        <img src="/logo.svg" alt="" className="h-[25vh] grayscale opacity-10"/>
                        <div className="text-base-content/30">No snippets open</div>
                    </div>
                </div>}
            </div>

            <div className="flex-auto order-1 lg:order-2 w-full lg:sticky lg:top-0 lg:h-svh lg:overflow-y-scroll">
                <div className="flex flex-col gap-3 h-full">
                    <div className="filter justify-end">
                        <input className="btn btn-sm btn-ghost filter-reset" type="radio" name="bag" aria-label="All"/>
                        <input className="btn btn-sm" type="radio" name="bag" aria-label="HKU"/>
                        <input className="btn btn-sm" type="radio" name="bag" aria-label="Dentistry"/>
                        <input className="btn btn-sm btn-soft btn-warning" type="radio" name="bag"
                               aria-label="Personal"/>
                    </div>

                    <div className="flex items-top gap-6">
                        <img src="/logo.svg" alt="snippetswiki logo" className="h-12"/>
                        <div>
                            <h1 className="text-4xl font-serif my-1">Snippet wiki</h1>
                            <h2 className="text-xl text-base-content/50">Collaborative knowledge building</h2>
                        </div>
                    </div>

                    <div className="flex items-center gap-6">
                        <AddButton addSnippet={addSnippet} addImportFiles={addImportFiles}/>

                        <Search snippets={snippets} openSnippet={openSnippet}/>

                        {/*<div className="inline-grid *:[grid-area:1/1]">*/}
                        {/*    <div className="status status-lg status-error animate-ping"></div>*/}
                        {/*    <div className="status status-lg status-error"></div>*/}
                        {/*</div>*/}
                    </div>

                    <div className="flex-1 tabs tabs-lift tabs-sm hidden lg:flex">
                        <input type="radio" name="my_tabs_3" className="tab" aria-label="Open"/>
                        <div className="tab-content bg-base-100 border-base-300 p-4">
                            <OpenSnippets snippets={openSnippets}
                                          openSnippet={openSnippet} closeSnippet={closeSnippet}/>
                        </div>

                        <input type="radio" name="my_tabs_3" className="tab" aria-label="Recent" defaultChecked/>
                        <div className="tab-content bg-base-100 border-base-300 p-4">
                            <RecentSnippets snippets={snippets} openSnippets={openSnippets}
                                            openSnippet={openSnippet} closeSnippet={closeSnippet}/>
                        </div>

                        <input type="radio" name="my_tabs_3" className="tab hidden xl:flex" aria-label="Map"/>
                        <div className="tab-content bg-base-100 border-base-300 p-4">
                            <div className="w-full h-full bg-base-200">
                                {snippets.length && <ConceptMap snippets={snippets}/>}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default App
