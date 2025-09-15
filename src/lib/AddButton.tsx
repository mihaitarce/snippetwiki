export function AddButton({addSnippet, addImportFiles}) {
    return (
        <div className="dropdown">
            <div tabIndex={0} role="button" className="btn btn-square btn-ghost">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                     stroke="currentColor" className="size-6">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15"/>
                </svg>
            </div>
            <ul tabIndex={0} className="dropdown-content menu bg-base-100 rounded-box z-1 w-52 p-2 shadow-sm mt-2">
                <li>
                    <a onClick={() => {
                        document?.activeElement?.blur();
                        addSnippet()
                    }}>
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                             stroke="currentColor" className="size-5">
                            <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15"/>
                        </svg>
                        New snippet
                    </a>
                </li>
                <li>
                    <label aria-label="Upload file">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                             stroke="currentColor" className="size-5">
                            <path strokeLinecap="round" strokeLinejoin="round"
                                  d="m18.375 12.739-7.693 7.693a4.5 4.5 0 0 1-6.364-6.364l10.94-10.94A3 3 0 1 1 19.5 7.372L8.552 18.32m.009-.01-.01.01m5.699-9.941-7.81 7.81a1.5 1.5 0 0 0 2.112 2.13"/>
                        </svg>
                        Upload file
                        <input className="hidden" type="file" onChange={(e) => {
                            addImportFiles(e.target.files)
                        }}/>
                    </label>
                </li>
                {/*<li>*/}
                {/*    <a onClick={() => {*/}
                {/*        document?.activeElement?.blur();*/}
                {/*    }}>*/}
                {/*        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}*/}
                {/*             stroke="currentColor" className="size-5">*/}
                {/*            <path strokeLinecap="round" strokeLinejoin="round"*/}
                {/*                  d="M3.75 3.75v4.5m0-4.5h4.5m-4.5 0L9 9M3.75 20.25v-4.5m0 4.5h4.5m-4.5 0L9 15M20.25 3.75h-4.5m4.5 0v4.5m0-4.5L15 9m5.25 11.25h-4.5m4.5 0v-4.5m0 4.5L15 15"/>*/}
                {/*        </svg>*/}
                {/*        New map*/}
                {/*    </a>*/}
                {/*</li>*/}
                {/*<li>*/}
                {/*    <a onClick={() => {*/}
                {/*        document?.activeElement?.blur();*/}
                {/*    }}>*/}
                {/*        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}*/}
                {/*             stroke="currentColor" className="size-5">*/}
                {/*            <path strokeLinecap="round" strokeLinejoin="round"*/}
                {/*                  d="M12 6.042A8.967 8.967 0 0 0 6 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 0 1 6 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 0 1 6-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0 0 18 18a8.967 8.967 0 0 0-6 2.292m0-14.25v14.25"/>*/}
                {/*        </svg>*/}
                {/*        New journal*/}
                {/*    </a>*/}
                {/*</li>*/}
            </ul>
        </div>
    )
}