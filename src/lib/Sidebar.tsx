export function Sidebar() {
    return (<div className="flex flex-col gap-4">
        <div className="card bg-base-100 max-w-[calc(65ch+3rem)]">
            <div className="card-body">
                <div className="flex justify-between">
                    <h2 className="text-3xl font-serif mb-2">
                        Talk:Hello, world 1
                    </h2>
                    <div>
                        <button className="btn btn-square btn-ghost text-base-content/50">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                 strokeWidth={1} stroke="currentColor" className="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="M6 18 18 6M6 6l12 12"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <div className="flex flex-col">
                    <div>
                        <div className="flex items-baseline justify-between gap-3 mb-2">
                            <div className="badge badge-soft badge-primary text-nowrap">user 1</div>
                            <div className="text-base-content/40">{new Date().toISOString()}</div>
                        </div>
                        <div className="prose">
                            <p>
                                Lorem ipsum dolor sit amet, consectetur adipisicing elit. At atque
                                consectetur
                                dicta, earum inventore, iusto nobis nostrum numquam odit officiis
                                placeat
                                repudiandae, sit soluta! Alias nihil odit quibusdam quod vero.
                            </p>
                        </div>
                    </div>

                    <hr className="border-base-300 mt-3 mb-4"/>

                    <div>
                        <div className="flex items-baseline justify-between gap-3 mb-2">
                            <div className="badge badge-soft badge-secondary text-nowrap">user 2
                            </div>
                            <div className="text-base-content/40">{new Date().toISOString()}</div>
                        </div>

                        <div className="prose">
                            <p>
                                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Adipisci
                                architecto
                                deleniti, doloribus ea eum, excepturi fugit inventore maxime nobis
                                odio officiis
                                perspiciatis placeat quaerat quam, quos sit sunt vitae voluptatum?
                            </p>
                            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Assumenda,
                                commodi,
                                doloremque doloribus enim in inventore ipsum modi optio pariatur
                                quam quis
                                repudiandae vero? Aliquam consectetur harum iusto magni, repellat
                                temporibus!</p>
                        </div>
                    </div>

                    <hr className="border-base-300 mt-3 mb-4"/>

                    <div>
                        <div className="flex items-baseline justify-between gap-3 mb-2">
                            <div className="badge badge-soft badge-accent text-nowrap">user 3</div>
                            <div className="text-base-content/40">{new Date().toISOString()}</div>
                        </div>

                        <div className="prose">
                            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Adipisci
                                consequuntur
                                delectus distinctio ea error impedit modi, obcaecati quis? Culpa
                                distinctio
                                ducimus eaque eligendi explicabo laudantium modi perspiciatis quas
                                quia
                                reiciendis.</p>
                        </div>
                    </div>

                    <hr className="border-base-300 mt-3 mb-4"/>

                    <div>
                        <div className="flex items-baseline justify-between gap-3 mb-2">
                            <div className="badge badge-soft badge-info text-nowrap">user 4</div>
                            <div className="text-base-content/40">{new Date().toISOString()}</div>
                        </div>

                        <div className="prose">
                            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Accusamus
                                aperiam
                                explicabo ipsa magnam officia optio ratione veniam! Ad, distinctio
                                eaque ex
                                ipsum neque obcaecati, optio provident quasi quod, tempore
                                ullam.</p>
                        </div>
                    </div>

                    <hr className="border-base-300 mt-3 mb-4"/>

                    <div className="flex gap-3">
                                            <textarea className="textarea flex-1"
                                                      placeholder="Enter message"></textarea>
                        <button className="btn btn-primary">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                 strokeWidth={1.5} stroke="currentColor" className="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="M6 12 3.269 3.125A59.769 59.769 0 0 1 21.485 12 59.768 59.768 0 0 1 3.27 20.875L5.999 12Zm0 0h7.5"/>
                            </svg>
                            Send
                        </button>
                    </div>
                </div>
            </div>
        </div>

        {/*<div className="card bg-base-100 max-w-[calc(65ch+3rem)]">*/}
        {/*    <div className="card-body">*/}
        {/*        <div className="flex justify-between">*/}
        {/*            <h2 className="text-3xl font-serif mb-2">*/}
        {/*                Map:Hello, world A*/}
        {/*            </h2>*/}
        {/*            <div>*/}
        {/*                <button className="btn btn-square btn-ghost text-base-content/50">*/}
        {/*                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"*/}
        {/*                         strokeWidth={1} stroke="currentColor" className="size-6 inline">*/}
        {/*                        <path strokeLinecap="round" strokeLinejoin="round"*/}
        {/*                              d="M5.25 8.25h15m-16.5 7.5h15m-1.8-13.5-3.9 19.5m-2.1-19.5-3.9 19.5"/>*/}
        {/*                    </svg>*/}
        {/*                </button>*/}
        {/*                <button className="btn btn-square btn-ghost text-base-content/50">*/}
        {/*                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"*/}
        {/*                         strokeWidth={1} stroke="currentColor" className="size-6">*/}
        {/*                        <path strokeLinecap="round" strokeLinejoin="round"*/}
        {/*                              d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/>*/}
        {/*                    </svg>*/}
        {/*                </button>*/}
        {/*                <button className="btn btn-square btn-ghost text-base-content/50">*/}
        {/*                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"*/}
        {/*                         strokeWidth={1} stroke="currentColor" className="size-6">*/}
        {/*                        <path strokeLinecap="round" strokeLinejoin="round"*/}
        {/*                              d="M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 0 1-.825-.242m9.345-8.334a2.126 2.126 0 0 0-.476-.095 48.64 48.64 0 0 0-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0 0 11.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155"/>*/}
        {/*                    </svg>*/}
        {/*                </button>*/}
        {/*                <button className="btn btn-square btn-ghost text-base-content/50">*/}
        {/*                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"*/}
        {/*                         strokeWidth={1} stroke="currentColor" className="size-6">*/}
        {/*                        <path strokeLinecap="round" strokeLinejoin="round"*/}
        {/*                              d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125"/>*/}
        {/*                    </svg>*/}
        {/*                </button>*/}
        {/*                <button className="btn btn-square btn-ghost text-base-content/50">*/}
        {/*                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"*/}
        {/*                         strokeWidth={1} stroke="currentColor" className="size-6">*/}
        {/*                        <path strokeLinecap="round" strokeLinejoin="round"*/}
        {/*                              d="M6 18 18 6M6 6l12 12"/>*/}
        {/*                    </svg>*/}
        {/*                </button>*/}
        {/*            </div>*/}
        {/*        </div>*/}

        {/*        <div className="h-128">*/}
        {/*            <Map/>*/}
        {/*        </div>*/}
        {/*    </div>*/}
        {/*</div>*/}

        <div className="card bg-base-100 max-w-[calc(65ch+3rem)]">
            <div className="card-body">
                <div className="flex justify-between">
                    <h2 className="text-3xl font-serif mb-2">
                        Hello, world B open in sidebar
                    </h2>
                    <div>
                        <button className="btn btn-square btn-ghost text-base-content/50">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                 strokeWidth={1} stroke="currentColor" className="size-6 inline">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="M5.25 8.25h15m-16.5 7.5h15m-1.8-13.5-3.9 19.5m-2.1-19.5-3.9 19.5"/>
                            </svg>
                        </button>
                        <button className="btn btn-square btn-ghost text-base-content/50">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                 strokeWidth={1} stroke="currentColor" className="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/>
                            </svg>
                        </button>
                        <button className="btn btn-square btn-ghost text-base-content/50">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                 strokeWidth={1} stroke="currentColor" className="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 0 1-.825-.242m9.345-8.334a2.126 2.126 0 0 0-.476-.095 48.64 48.64 0 0 0-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0 0 11.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155"/>
                            </svg>
                        </button>
                        <button className="btn btn-square btn-ghost text-base-content/50">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                 strokeWidth={1} stroke="currentColor" className="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125"/>
                            </svg>
                        </button>
                        <button className="btn btn-square btn-ghost text-base-content/50">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                 strokeWidth={1} stroke="currentColor" className="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="M6 18 18 6M6 6l12 12"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <div
                    className="prose prose-headings:font-serif prose-headings:font-normal prose-headings:my-2">
                    <p>
                        Lorem ipsum dolor sit amet, consectetur adipisicing elit. At atque
                        consectetur
                        dicta, earum inventore, iusto nobis nostrum numquam odit officiis placeat
                        repudiandae, sit soluta! Alias nihil odit quibusdam quod vero.
                    </p>
                    <p>
                        Lorem ipsum dolor sit amet, consectetur adipisicing elit. Adipisci
                        architecto
                        deleniti, doloribus ea eum, excepturi fugit inventore maxime nobis odio
                        officiis
                        perspiciatis placeat quaerat quam, quos sit sunt vitae voluptatum?
                    </p>
                    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Assumenda, commodi,
                        doloremque doloribus enim in inventore ipsum modi optio pariatur quam quis
                        repudiandae vero? Aliquam consectetur harum iusto magni, repellat
                        temporibus!</p>
                    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Adipisci
                        consequuntur
                        delectus distinctio ea error impedit modi, obcaecati quis? Culpa distinctio
                        ducimus eaque eligendi explicabo laudantium modi perspiciatis quas quia
                        reiciendis.</p>
                    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Accusamus aperiam
                        explicabo ipsa magnam officia optio ratione veniam! Ad, distinctio eaque ex
                        ipsum neque obcaecati, optio provident quasi quod, tempore ullam.</p>
                </div>
            </div>
        </div>
    </div>)
}