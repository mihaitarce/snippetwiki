export function Import({files, cancelImport}) {
    return (<div className="card bg-base-100 p-6">
            <div className="flex items-center justify-between mb-1">
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

            <ul className="mt-3">
                {files.map((file) => (
                    <li key={file.name} className="flex items-center gap-4 py-4">
                        <input type="checkbox" className="checkbox checkbox-primary" defaultChecked/>

                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={0.75}
                             stroke="currentColor" className="flex-none size-16 text-base-content/30">
                            <path strokeLinecap="round" strokeLinejoin="round"
                                  d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z"/>
                        </svg>

                        <div>
                            {file.name}
                            <div className="text-base-content/50 text-sm">
                                {Intl.NumberFormat().format(file.size)} bytes
                            </div>
                            <div className="text-base-content/50 text-sm">
                                {file.type}
                            </div>
                        </div>
                    </li>
                ))}
            </ul>
        </div>
    )
}