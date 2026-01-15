<script>
    import NumberFlow from '@number-flow/svelte';
    import { onMount } from 'svelte';

    let { number, item } = $props();

    let animated = $state(false);

    function pluralize(count, noun, suffix = 's') {
      return `${noun}${count !== 1 ? suffix : ''}`;
    }

    onMount(() => {
        setInterval(() => {
            animated = true;
        }, 200);
    })
</script>

<NumberFlow value={number} {animated} /> {pluralize(number, item)}
