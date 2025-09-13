export function Snippet({snippet}) {
    return (
        <li className="card bg-base-100 p-3 min-h-24">
            <div className="flex gap-2 items-center">
                {snippet.name}: {snippet.value}
                <button className="btn">Update</button>
                <button className="btn btn-error">Delete</button>
            </div>
        </li>
    )
}