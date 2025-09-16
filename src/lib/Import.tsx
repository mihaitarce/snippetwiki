import clsx from "clsx";

export function Import({files, snippets, cancelImport}) {
    function fileNameExists(filename) {
        return snippets.find((snippet) => snippet.title === filename) !== undefined
    }

    return (<div className="card bg-base-100">
            <div className="card-body">
                <div className="flex items-center justify-between mb-3">
                    <h1 className="font-serif text-3xl">Import</h1>
                    <div className="flex gap-3">
                        <button
                            className="btn btn-primary">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                                 stroke="currentColor" className="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5m-13.5-9L12 3m0 0 4.5 4.5M12 3v13.5"/>
                            </svg>
                            Upload
                        </button>
                        <button
                            className="btn btn-square btn-ghost border-0 text-base-content/50 hover:text-base-content"
                            onClick={cancelImport}>
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                 strokeWidth={1.5} stroke="currentColor" className="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round" d="M6 18 18 6M6 6l12 12"/>
                            </svg>
                        </button>
                    </div>
                </div>

                {/*<div role="alert" className="alert alert-soft alert-warning mb-3">*/}
                {/*    <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 shrink-0 stroke-current" fill="none"*/}
                {/*         viewBox="0 0 24 24">*/}
                {/*        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"*/}
                {/*              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>*/}
                {/*    </svg>*/}
                {/*    <span>Some file names already exist. Please rename them.</span>*/}
                {/*</div>*/}

                <ul className="flex flex-col gap-4 p-1 overflow-x-scroll">
                    {files.map((file) => (
                        <li key={file.name} className="flex items-center gap-2">
                            <input type="checkbox" className="checkbox" defaultChecked/>

                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={0.75}
                                 stroke="currentColor" className="flex-none size-12 text-base-content/30">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z"/>
                            </svg>

                            <div className="flex-1">
                                <label
                                    className={clsx({"input mb-1": true, "input-warning": fileNameExists(file.name)})}>
                                    <input type="text" placeholder="Enter file name" value={file.name}/>
                                    {fileNameExists(file.name) &&
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                             strokeWidth={1.5} stroke="currentColor"
                                             className="h-[1.5em] opacity-50 text-warning">
                                            <path strokeLinecap="round" strokeLinejoin="round"
                                                  d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"/>
                                        </svg>}
                                </label>
                                <div className="text-base-content/50 text-sm">
                                    {Intl.NumberFormat().format(file.size)} bytes
                                </div>
                            </div>
                        </li>
                    ))}
                </ul>
            </div>
        </div>
    )
}