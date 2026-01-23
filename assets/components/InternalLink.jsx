import React from "react";
import { createReactInlineContentSpec } from "@blocknote/react";

// The InternalLink inline content.
export const InternalLink = createReactInlineContentSpec(
  {
    type: "InternalLink",
    propSchema: {
      id: {},
      title: {},
    },
    content: "none",
  },
  {
    render: (props) => (
      <a className="internal-link"
         onClick={(e) => window.liveSocket.js().push(e.target, "open_snippet", { value: { id: String(props.inlineContent.props.id) } })}>
        {props.inlineContent.props.title}
      </a>
    ),
  },
);