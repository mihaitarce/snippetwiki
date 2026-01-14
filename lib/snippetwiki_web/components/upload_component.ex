defmodule SnippetwikiWeb.UploadComponent do
  use Phoenix.Component

  alias FileSize

  def upload(assigns) do
    ~H"""
      <div class="card bg-base-100">
            <div class="card-body">
                <div class="flex items-center justify-between mb-3">
                    <h1 class="font-serif text-3xl">Import</h1>
                    <div class="flex gap-3">
                        <button phx="save_upload"
                            class="btn btn-primary">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                                stroke="currentColor" class="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                      d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5m-13.5-9L12 3m0 0 4.5 4.5M12 3v13.5"/>
                            </svg>
                            Upload
                        </button>
                        <button phx-click="cancel_all_uploads"
                            class="btn btn-square btn-ghost border-0 text-base-content/50 hover:text-base-content">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                strokeWidth={1.5} stroke="currentColor" class="size-6">
                                <path strokeLinecap="round" strokeLinejoin="round" d="M6 18 18 6M6 6l12 12"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <div role="alert" class="alert alert-soft alert-warning mb-3">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none"
                        viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                    </svg>
                    <span>Some file names already exist. Please rename them.</span>
                </div>

                <%!-- render each document entry --%>
                <article :for={entry <- @uploads.documents.entries} class="flex items-center gap-2 overflow-x-scroll">
                    <figure>
                        <.live_img_preview entry={entry} class="max-h-32" />

                        <%!-- <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={0.75}
                            stroke="currentColor" class="flex-none size-12 text-base-content/30">
                            <path strokeLinecap="round" strokeLinejoin="round"
                                    d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z"/>
                        </svg> --%>
                    </figure>

                    <div>
                        {entry.client_name}
                        <label class="input mb-1">
                            <%!-- "input-warning": fileNameExists(file.name)} --%>
                            <input type="text" placeholder="Enter file name" />
                            <%!-- {fileNameExists(file.name) && --%>
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                    strokeWidth={1.5} stroke="currentColor"
                                    class="h-[1.5em] opacity-50 text-warning">
                                    <path strokeLinecap="round" strokeLinejoin="round"
                                            d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"/>
                                </svg>
                        </label>
                    </div>

                    <div class="text-base-content/50 text-sm">
                        {entry.client_size |> FileSize.new |> FileSize.convert(:mb) |> FileSize.format([precision: 2])}
                    </div>

                    <%!-- entry.progress will update automatically for in-flight entries --%>
                    <progress value={entry.progress} max="100"> {entry.progress}% </progress>

                    <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
                    <button type="button" phx-click="cancel_upload" phx-value-ref={entry.ref} aria-label="cancel">&times;</button>

                    <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
                    <p :for={err <- upload_errors(@uploads.documents, entry)} class="alert alert-danger">{error_to_string(err)}</p>
                </article>

                <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
                <p :for={err <- upload_errors(@uploads.documents)} class="alert alert-danger">
                    {error_to_string(err)}
                </p>
            </div>
        </div>
      """
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

end
