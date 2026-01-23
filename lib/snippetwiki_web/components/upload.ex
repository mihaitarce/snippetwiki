defmodule SnippetwikiWeb.UploadComponent do
  use Phoenix.Component

  import SnippetwikiWeb.CoreComponents

  def upload(assigns) do
    ~H"""
      <div class="card bg-base-100" phx-drop-target={@uploads.documents.ref}>
            <div class="card-body">
                <div class="flex items-center justify-between mb-3">
                    <h1 class="font-serif text-3xl">Import files</h1>
                    <div class="flex gap-3">
                        <button phx="save_upload"
                            form="upload"
                            class="btn btn-primary"
                            disabled={not Enum.empty?(@uploads.documents.errors)}>
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

                <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
                <p :for={err <- upload_errors(@uploads.documents)} class="alert alert-soft alert-error">
                    {error_to_string(err)}
                </p>

                <%!-- render each document entry --%>
                <div class="flex flex-col gap-4 overflow-x-scroll">
                    <article :for={entry <- @uploads.documents.entries} class="flex items-center gap-4">
                        <figure class="w-36">
                            <%= if String.starts_with?(entry.client_type, "image/") do %>
                                <.live_img_preview entry={entry} class="max-h-48 mx-auto" />
                            <% else %>
                                <%= if entry.client_type == "application/pdf" do %>
                                    <.icon name="hero-document" class="size-24 text-base-content/16" />
                                <% else %>
                                    <.icon name="hero-exclamation-triangle" class="size-24 text-base-content/16" />
                                <% end %>
                            <% end %>

                            <%!-- <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={0.75}
                                stroke="currentColor" class="flex-none size-12 text-base-content/30">
                                <path strokeLinecap="round" strokeLinejoin="round"
                                        d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z"/>
                            </svg> --%>
                        </figure>

                        <div class="grow flex flex-col gap-1">
                            <div class="flex justify-between gap-2">
                                <div class="max-w-32 lg:max-w-72 truncate">{entry.client_name}</div>
                                <div class="text-base-content/50 text-sm text-nowrap">
                                    {entry.client_size |> FileSize.new |> FileSize.convert(:mb) |> FileSize.format([precision: 2])}
                                </div>
                            </div>

                            <%!-- entry.progress will update automatically for in-flight entries --%>
                            <div>
                                <progress class="w-full" value={entry.progress} max="100"> {entry.progress}% </progress>
                            </div>

                            <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
                            <p :for={err <- upload_errors(@uploads.documents, entry)} class="alert alert-soft alert-error">{error_to_string(err)}</p>
                        </div>

                        <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
                        <.button phx-click="cancel_upload" phx-value-ref={entry.ref} aria-label="cancel" variant="error">
                            <.icon name="hero-trash" class="h-[1.5em]" />
                        </.button>
                    </article>
                </div>
            </div>
        </div>
      """
  end

  defp error_to_string(:too_large), do: "File is too large"
  defp error_to_string(:too_many_files), do: "Too many files selected"
  defp error_to_string(:not_accepted), do: "File type not supported"
  defp error_to_string(:already_exists), do: "File name already exists"

end
