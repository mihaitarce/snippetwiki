import React from "react";
import ReactDOM from "react-dom/client";
import Editor from "../components/Editor";
import Viewer from "../components/Viewer";

import NumberFlow from '@number-flow/react';

import '@fontsource-variable/noto-sans';
import '@fontsource-variable/noto-serif';

export const hooks = {
    Editor: {
        mounted() {
            const id = this.el.dataset.id
            const textareaElement = this.el.parentNode.querySelector('textarea')
            const root = ReactDOM.createRoot(this.el);
            root.render(<Editor id={id} textarea={textareaElement} />);
        }
    },

    Viewer: {
        mounted() {
            const id = this.el.dataset.id
            const textareaElement = this.el.parentNode.querySelector('textarea')
            const root = ReactDOM.createRoot(this.el);
            root.render(<Viewer id={id} textarea={textareaElement} />);
        }
    },

    Number: {
        root: null,

        number() {
            return this.el.dataset.number
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