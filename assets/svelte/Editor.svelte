<script>
    import { onMount } from 'svelte';
    
    import "quill/dist/quill.core.css";
    import "quill/dist/quill.snow.css";

    import Quill from 'quill';

    let { content } = $props()

    let editorElement

    let quill

    onMount(() => {
        quill = new Quill(editorElement, {
            theme: 'snow',
        });

        const form = editorElement.closest('form')
        const textarea = form.querySelector('textarea')

        // Load HTML content from textarea
        const delta = quill.clipboard.convert({html: textarea.value})
        quill.setContents(delta, 'silent')

        // Save HTML content to textarea
        form.addEventListener('submit', (e) => {    
            textarea.value = quill.getSemanticHTML().replaceAll("&nbsp;", " ")
        })
    })
</script>

<div bind:this={editorElement}></div>