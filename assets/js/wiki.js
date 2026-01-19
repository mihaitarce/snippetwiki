import React from "react";
import ReactDOM from "react-dom/client";
import BlockNote from "../components/BlockNote";

import NumberFlow from '@number-flow/react';

import '@fontsource-variable/noto-sans';
import '@fontsource-variable/noto-serif';

export const hooks = {
    BlockNote: {
        mounted() {
            const textareaElement = this.el.parentNode.querySelector('textarea')
            const root = ReactDOM.createRoot(this.el);
            root.render(<BlockNote textarea={textareaElement} />);
        }
    },

    Number: {
        root: null,

        number() {
            return this.el.dataset.number
        },

        item() {
            return this.el.dataset.item
        },

        updateComponent() {
            this.root.render(<NumberFlow value={this.number()} />)
        },

        mounted() {
            this.root = ReactDOM.createRoot(this.el)
            this.updateComponent()
        },

        updated() {
            this.updateComponent()
        }
    }
}