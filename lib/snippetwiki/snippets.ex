defmodule Snippetwiki.Snippets do
  @moduledoc """
  The Snippets context.
  """

  import Ecto.Query, warn: false
  alias Snippetwiki.Repo

  alias Snippetwiki.Snippets.{User, UserToken, UserNotifier}

    ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.email_changeset(attrs)
    |> Repo.insert()
  end

  ## Settings

  @doc """
  Checks whether the user is in sudo mode.

  The user is in sudo mode when the last authentication was done no further
  than 20 minutes ago. The limit can be given as second argument in minutes.
  """
  def sudo_mode?(user, minutes \\ -20)

  def sudo_mode?(%User{authenticated_at: ts}, minutes) when is_struct(ts, DateTime) do
    DateTime.after?(ts, DateTime.utc_now() |> DateTime.add(minutes, :minute))
  end

  def sudo_mode?(_user, _minutes), do: false

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  See `Snippetwiki.Snippets.User.email_changeset/3` for a list of supported options.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}, opts \\ []) do
    User.email_changeset(user, attrs, opts)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    Repo.transact(fn ->
      with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
           %UserToken{sent_to: email} <- Repo.one(query),
           {:ok, user} <- Repo.update(User.email_changeset(user, %{email: email})),
           {_count, _result} <-
             Repo.delete_all(from(UserToken, where: [user_id: ^user.id, context: ^context])) do
        {:ok, user}
      else
        _ -> {:error, :transaction_aborted}
      end
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  See `Snippetwiki.Snippets.User.password_changeset/3` for a list of supported options.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}, opts \\ []) do
    User.password_changeset(user, attrs, opts)
  end

  @doc """
  Updates the user password.

  Returns a tuple with the updated user, as well as a list of expired tokens.

  ## Examples

      iex> update_user_password(user, %{password: ...})
      {:ok, {%User{}, [...]}}

      iex> update_user_password(user, %{password: "too short"})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> update_user_and_delete_all_tokens()
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.

  If the token is valid `{user, token_inserted_at}` is returned, otherwise `nil` is returned.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Gets the user with the given magic link token.
  """
  def get_user_by_magic_link_token(token) do
    with {:ok, query} <- UserToken.verify_magic_link_token_query(token),
         {user, _token} <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Logs the user in by magic link.

  There are three cases to consider:

  1. The user has already confirmed their email. They are logged in
     and the magic link is expired.

  2. The user has not confirmed their email and no password is set.
     In this case, the user gets confirmed, logged in, and all tokens -
     including session ones - are expired. In theory, no other tokens
     exist but we delete all of them for best security practices.

  3. The user has not confirmed their email but a password is set.
     This cannot happen in the default implementation but may be the
     source of security pitfalls. See the "Mixing magic link and password registration" section of
     `mix help phx.gen.auth`.
  """
  def login_user_by_magic_link(token) do
    {:ok, query} = UserToken.verify_magic_link_token_query(token)

    case Repo.one(query) do
      # Prevent session fixation attacks by disallowing magic links for unconfirmed users with password
      {%User{confirmed_at: nil, hashed_password: hash}, _token} when not is_nil(hash) ->
        raise """
        magic link log in is not allowed for unconfirmed users with a password set!

        This cannot happen with the default implementation, which indicates that you
        might have adapted the code to a different use case. Please make sure to read the
        "Mixing magic link and password registration" section of `mix help phx.gen.auth`.
        """

      {%User{confirmed_at: nil} = user, _token} ->
        user
        |> User.confirm_changeset()
        |> update_user_and_delete_all_tokens()

      {user, token} ->
        Repo.delete!(token)
        {:ok, {user, []}}

      nil ->
        {:error, :not_found}
    end
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm-email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Delivers the magic link login instructions to the given user.
  """
  def deliver_login_instructions(%User{} = user, magic_link_url_fun)
      when is_function(magic_link_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "login")
    Repo.insert!(user_token)
    UserNotifier.deliver_login_instructions(user, magic_link_url_fun.(encoded_token))
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(from(UserToken, where: [token: ^token, context: "session"]))
    :ok
  end

  ## Token helper

  defp update_user_and_delete_all_tokens(changeset) do
    Repo.transact(fn ->
      with {:ok, user} <- Repo.update(changeset) do
        tokens_to_expire = Repo.all_by(UserToken, user_id: user.id)

        Repo.delete_all(from(t in UserToken, where: t.id in ^Enum.map(tokens_to_expire, & &1.id)))

        {:ok, {user, tokens_to_expire}}
      end
    end)
  end


  alias Snippetwiki.Snippets.{Snippet, Revision, Like}
  alias Snippetwiki.Snippets.Scope

  @doc """
  Returns the list of snippets.

  ## Examples

      iex> list_snippets(scope)
      [%Snippet{}, ...]

  """
  def list_snippets(%Scope{} = scope) do
    likes_count = from(l in Like, where: l.snippet_id == parent_as(:snippet).id, select: count())

    query = from s in Snippet, as: :snippet,
      select_merge: %{like_count: subquery(likes_count)},
      order_by: [desc: :updated_at, desc: :id]

    Repo.all_by(query, user_id: scope.user.id)
  end

  def search_snippets(%Scope{} = scope, query_string \\ nil) do
    query = from s in Snippet, as: :snippet,
      where: is_nil(s.namespace),
      order_by: [desc: :updated_at, desc: :id]

    if is_nil(query_string) do
      query
    else
      query
      |> where([s], ilike(s.title, ^("%#{query_string}%")))
    end
    |> Repo.all_by(user_id: scope.user.id)
  end

  @doc """
  Gets a single snippet.

  Raises `Ecto.NoResultsError` if the Snippet does not exist.

  ## Examples

      iex> get_snippet!(scope, 123)
      %Snippet{}

      iex> get_snippet!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_snippet!(%Scope{} = scope, id) do
    Repo.get_by!(Snippet, id: id, user_id: scope.user.id)
  end

  def find_snippet(%Scope{} = scope, title, namespace \\ nil) do
    query = from s in Snippet, as: :snippet,
      where: s.title == ^title and s.namespace == ^namespace,
      left_join: r in assoc(s, :revisions),
      select_merge: %{content: r.content, content_type: r.content_type},
      order_by: [desc: r.version]

    Repo.get_by(query, user_id: scope.user.id)
  end

  def find_snippet!(%Scope{} = scope, title, namespace \\ nil) do
    query = from s in Snippet, as: :snippet,
      where: s.title == ^title and s.namespace == ^namespace,
      left_join: r in assoc(s, :revisions),
      select_merge: %{content: r.content, content_type: r.content_type},
      order_by: [desc: r.version]

    Repo.get_by!(query, user_id: scope.user.id)
  end

  def with_content(snippet) do
    likes_count = from(l in Like, where: l.snippet_id == parent_as(:snippet).id, select: count())

    query = from s in Snippet, as: :snippet,
      where: s.id == ^snippet.id,
      left_join: r in assoc(s, :revisions),
      select_merge: %{like_count: subquery(likes_count)},
      select_merge: %{content: r.content, content_type: r.content_type},
      order_by: [desc: r.version],
      limit: 1

    Repo.one(query)
  end

  @doc """
  Creates a snippet.

  ## Examples

      iex> create_snippet(scope, %{field: value})
      {:ok, %Snippet{}}

      iex> create_snippet(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_snippet(%Scope{} = scope, attrs) do
    with {:ok, snippet = %Snippet{}} <-
           %Snippet{}
           |> Snippet.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_snippet(scope, {:created, snippet})
      {:ok, snippet}
    end
  end

  @doc """
  Updates a snippet.

  ## Examples

      iex> update_snippet(scope, snippet, %{field: new_value})
      {:ok, %Snippet{}}

      iex> update_snippet(scope, snippet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_snippet(%Scope{} = scope, %Snippet{} = snippet, attrs) do
    true = snippet.user_id == scope.user.id

    with {:ok, snippet = %Snippet{}} <-
           snippet
           |> Snippet.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_snippet(scope, {:updated, snippet})
      {:ok, snippet}
    end
  end

@doc """
  Deletes a snippet.

  ## Examples

      iex> delete_snippet(scope, snippet)
      {:ok, %Snippet{}}

      iex> delete_snippet(scope, snippet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_snippet(%Scope{} = scope, %Snippet{} = snippet) do
    true = snippet.user_id == scope.user.id

    with {:ok, snippet = %Snippet{}} <-
           Repo.delete(snippet) do
      broadcast_snippet(scope, {:deleted, snippet})
      {:ok, snippet}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking snippet changes.

  ## Examples

      iex> change_snippet(scope, snippet)
      %Ecto.Changeset{data: %Snippet{}}

  """
  def change_snippet(%Scope{} = scope, %Snippet{} = snippet, attrs \\ %{}) do
    true = snippet.user_id == scope.user.id

    Snippet.changeset(snippet, attrs, scope)
  end

  # Extra functions

  def create_draft(%Scope{} = scope, %Snippet{} = snippet) do
    Snippet
    |> where(id: ^snippet.id)
    |> Repo.update_all(set: [has_draft: true])

    broadcast_snippet(scope, {:updated, snippet})
    {:ok, snippet}
  end

  def discard_draft(%Scope{} = scope, %Snippet{} = snippet) do
    Snippet
    |> where(id: ^snippet.id)
    |> Repo.update_all(set: [has_draft: false])

    broadcast_snippet(scope, {:updated, snippet})
    {:ok, snippet}
  end

  def create_new_revision(%Scope{} = scope, snippet, attrs, content, content_type \\ "text/html") do
    # TODO Use transaction

    # Create new revision
    {:ok, _} = Repo.insert(%Revision{snippet: snippet, content: content, content_type: content_type})

    # Update snippet
    {:ok, snippet} = update_snippet(scope, snippet, attrs)
    {:ok, with_content(snippet)}
  end

  def increment_views(%Scope{} = scope, id) do
      snippet = get_snippet!(scope, id)

      Snippet
      |> where(id: ^id)
      |> Repo.update_all(inc: [views: 1])

      broadcast_snippet(scope, {:updated, snippet})
      {:ok, snippet}
  end


  def like_snippet(%Scope{} = scope, snippet) do
    Repo.insert(%Like{ snippet: snippet, user_id: scope.user.id }, on_conflict: :nothing)

    broadcast_snippet(scope, {:updated, snippet})
    {:ok, snippet}
  end


  @doc """
  Subscribes to scoped notifications about any snippet changes.

  The broadcasted messages match the pattern:

    * {:created, %Snippet{}}
    * {:updated, %Snippet{}}
    * {:deleted, %Snippet{}}

  """
  def subscribe_snippets(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Snippetwiki.PubSub, "user:#{key}:snippets")
  end

  defp broadcast_snippet(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Snippetwiki.PubSub, "user:#{key}:snippets", message)
  end
end
