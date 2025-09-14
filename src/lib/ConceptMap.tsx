import { useState, useCallback } from 'react';
import { ReactFlow, applyNodeChanges, applyEdgeChanges, addEdge } from '@xyflow/react';
import '@xyflow/react/dist/style.css';

export function ConceptMap({snippets}) {
    const nodesFromSnippets = snippets.map((snippet, index) => {
        return { id: snippet.id, position: { x: 0, y: 100 * index }, data: { label: snippet.name } };
    })
    const edgesFromSnippets = [{ id: 'n1-n2', source: snippets[0].id, target: snippets[1].id }]

    const [nodes, setNodes] = useState(nodesFromSnippets);
    const [edges, setEdges] = useState(edgesFromSnippets);

    const onNodesChange = useCallback(
        (changes) => setNodes((nodesSnapshot) => applyNodeChanges(changes, nodesSnapshot)),
        [],
    );
    const onEdgesChange = useCallback(
        (changes) => setEdges((edgesSnapshot) => applyEdgeChanges(changes, edgesSnapshot)),
        [],
    );
    const onConnect = useCallback(
        (params) => setEdges((edgesSnapshot) => addEdge(params, edgesSnapshot)),
        [],
    );

    const proOptions = { hideAttribution: true };

    return (
        <ReactFlow
            nodes={nodes}
            edges={edges}
            onNodesChange={onNodesChange}
            onEdgesChange={onEdgesChange}
            onConnect={onConnect}
            fitView
            proOptions={proOptions}
        />
    );
}