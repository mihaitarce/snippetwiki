import {scoresCollection} from "./collection.ts";

export function SnippetList({snippets}) {
    function updateScore(score) {
        scoresCollection.update(score.id, (draft) => {
            draft.value = 55;
        })
    }

    function deleteScore(score) {
        scoresCollection.delete(score.id)
    }

    return (
        <ul className="flex flex-col gap-4">
            {snippets.map((snippet) =>
                <li key={snippet.id} className="card bg-base-100 p-3">
                    <div className="flex items-center justify-between mb-4">
                        <h1 className="font-serif text-3xl">{snippet.name}: {snippet.value}</h1>
                        <div className="flex gap-3">
                            <button className="btn" onClick={() => updateScore(snippet)}>Update</button>
                            <button className="btn btn-error" onClick={() => deleteScore(snippet)}>Delete</button>
                        </div>
                    </div>

                    <div className="prose prose-headings:font-serif prose-headings:font-normal prose-headings:my-2">
                        <h2>Hello, world!</h2>
                        <p>
                            Et eligendi aut cupiditate voluptatibus quia sit architecto. Ut suscipit facere rerum ut et
                            repellat. Distinctio non officiis commodi iste repellendus aut.
                        </p>
                        <p>
                            In et voluptas non modi. Ut asperiores et voluptatem consectetur. Ducimus asperiores
                            laudantium
                            enim. Eius rerum illo ut. Necessitatibus deserunt aspernatur sapiente aliquid harum nihil.
                        </p>

                        {/*<h2>Hey there!</h2>*/}
                        {/*<p>*/}
                        {/*    Quae vel nemo architecto accusantium nulla corrupti quia ab. Culpa reiciendis omnis hic et est. Et vel recusandae dolorem veritatis at omnis non aliquid. Voluptate atque et consequuntur perferendis enim.*/}
                        {/*</p>*/}
                        {/*<p>*/}
                        {/*    Ullam excepturi totam eligendi sit. Nostrum voluptatem deserunt quod dolorum quidem. Occaecati eum alias quos eligendi voluptas neque mollitia. Vel cumque nulla repellat. Veritatis numquam est enim.*/}
                        {/*</p>*/}
                        {/*<p>*/}
                        {/*    Non corporis incidunt porro doloribus cumque enim tempora totam. Perspiciatis dicta dolorum ut. Numquam et facere unde inventore similique.*/}
                        {/*</p>*/}
                    </div>
                </li>
            )}
        </ul>
    )
}