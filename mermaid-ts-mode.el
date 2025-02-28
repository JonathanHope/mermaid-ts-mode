;;; mermaid-ts-mode.el --- Major mode for Mermaid -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Jonathan Hope

;; Author: Jonathan Hope <jhope@theflatfield.net>
;; Version: 1.0
;; Keywords: mermaid, languages
;; Package-Requires: ((emacs "29.1"))
;; Homepage: https://github.com/JonathanHope/mermaid-ts-mode

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Mermaid is a language to programatically define diagrams.
;; This is a major mode for mermaid built on tree sitter.

;;; Code:

(require 'treesit)
(eval-when-compile (require 'rx))

(declare-function treesit-parser-create "treesit.c")
(declare-function treesit-query-capture "treesit.c")
(declare-function treesit-induce-sparse-tree "treesit.c")
(declare-function treesit-node-child "treesit.c")
(declare-function treesit-node-start "treesit.c")
(declare-function treesit-node-type "treesit.c")

(defgroup mermaid-ts nil
  "Support mermaid code."
  :link '(url-link "http://mermaid.js.org/")
  :group 'languages)

(defcustom mermaid-ts-mode-hook nil
  "Hook called by `mermaid-ts-mode'."
  :type 'hook
  :group 'mermaid-ts)

(defcustom mermaid-ts-indent-level 2
  "The tab width to use when indenting."
  :type 'integer
  :group 'mermaid-ts)

(defvar mermaid-ts--syntax-table
  (let ((table (make-syntax-table)))
    table)
  "Syntax table for `mermaid-ts-mode'.")

(defvar mermaid-ts--treesit-font-lock-rules
  (treesit-font-lock-rules

   ;; Common

   :language 'mermaid
   :feature 'constants
   '(["tb" "td" "bt" "rl" "lr" "left of" "right of" "over"] @font-lock-constant-face
     (direction_lr) @font-lock-constant-face
     (direction_rl) @font-lock-constant-face
     (direction_tb) @font-lock-constant-face
     (direction_bt) @font-lock-constant-face
     (er_attribute_type) @font-lock-constant-face
     (annotation) @font-lock-constant-face
     (gantt_date_format) @font-lock-constant-face
     (gantt_axis_format) @font-lock-constant-face
     (pie_value) @font-lock-constant-face)

   :language 'mermaid
   :feature 'comments
   '((comment) @font-lock-comment-face)
   
   :language 'mermaid
   :feature 'keywords
   '(["flowchart" "subgraph" "end" "direction" "sequenceDiagram" "participant" "actor" "as" "stateDiagram-v2" "stateDiagram" "state " "note " "erdiagram" "classDiagram" "class" "gantt" "title" "dateformat" "section" "axisformat" "pie" "opt" "loop"] @font-lock-keyword-face
     (state_annotation_choice) @font-lock-keyword-face
     (state_annotation_fork) @font-lock-keyword-face
     (state_annotation_join) @font-lock-keyword-face)

   :language 'mermaid
   :feature 'nodes
   '((flow_vertex_id) @font-lock-type-face
     (sequence_actor) @font-lock-type-face
     (state_name) @font-lock-type-face
     (state_id) @font-lock-type-face
     (er_entity_name) @font-lock-type-face
     (class_name) @font-lock-type-face
     (gantt_section) @font-lock-type-face
     (gantt_task_data) @font-lock-type-face)

   :language 'mermaid
   :feature 'links
   '((flow_link_arrow) @font-lock-keyword-face
     (flow_link_arrow_start) @font-lock-keyword-face
     (sequence_signal_type) @font-lock-keyword-face
     (state_arrow) @font-lock-keyword-face
     (er_relation) @font-lock-keyword-face
     (class_relation) @font-lock-keyword-face)

   :language 'mermaid
   :feature 'text
   '((flow_text_quoted) @font-lock-string-face
     (flow_text_literal) @font-lock-string-face
     (flow_arrow_text) @font-lock-string-face
     (flow_vertex_text) @font-lock-string-face
     (sequence_text) @font-lock-string-face
     (sequence_alias) @font-lock-string-face
     (state_description) @font-lock-string-face
     (er_role) @font-lock-string-face
     (cardinality) @font-lock-string-face
     (gantt_task_text) @font-lock-string-face
     (pie_title) @font-lock-string-face
     (pie_label) @font-lock-string-face))
  "Mermaid font-lock settings.")

(defvar mermaid-ts--indent-rules
  `((mermaid
     ((node-is "diagram_flow") column-0 0)
     ((node-is "diagram_sequence") column-0 0)
     ((node-is "diagram_state") column-0 0)
     ((node-is "diagram_er") column-0 0)
     ((node-is "diagram_class") column-0 0)
     ((node-is "diagram_gantt") column-0 0)
     ((node-is "diagram_pie") column-0 0)
     ((node-is "end") parent-bol 0)
     ((parent-is "flow_stmt_subgraph_inner") parent-bol 0)
     ((parent-is "er_stmt_entity_block_inner") parent-bol 0)
     ((node-is "}") parent-bol 0)
     ((parent-is "diagram_flow") parent-bol mermaid-ts-indent-level)
     ((parent-is "diagram_sequence") parent-bol mermaid-ts-indent-level)
     ((parent-is "diagram_state") parent-bol mermaid-ts-indent-level)
     ((parent-is "diagram_er") parent-bol mermaid-ts-indent-level)
     ((parent-is "diagram_class") parent-bol mermaid-ts-indent-level)
     ((parent-is "diagram_gantt") parent-bol mermaid-ts-indent-level)
     ((parent-is "diagram_pie") parent-bol mermaid-ts-indent-level)
     ((parent-is "state_composite_body") parent-bol mermaid-ts-indent-level)
     ((parent-is "er_stmt_entity_block") parent-bol mermaid-ts-indent-level)
     ((parent-is "class_stmt_class") parent-bol mermaid-ts-indent-level)
     ((parent-is "subgraph") parent-bol mermaid-ts-indent-level)
     ((parent-is "sequence_stmt_opt") parent-bol mermaid-ts-indent-level)
     ((parent-is "sequence_stmt_loop") parent-bol mermaid-ts-indent-level))))

;;;###autoload
(define-derived-mode mermaid-ts-mode prog-mode "Mermaid"
  :group 'mermaid-ts
  :syntax-table mermaid-ts--syntax-table
  
  (unless (treesit-ready-p 'mermaid)
    (error "Tree-sitter for Mermaid isn't available"))

  (treesit-parser-create 'mermaid)
  
  (setq-local comment-start "%%")
  (setq-local treesit-simple-indent-rules mermaid-ts--indent-rules)
  (setq-local treesit-font-lock-feature-list '((comments)
                                               (constants keywords text links)
                                               (nodes)))
  (setq-local treesit-font-lock-settings mermaid-ts--treesit-font-lock-rules)
  
  (treesit-major-mode-setup))
   
(provide 'mermaid-ts-mode)
;;; mermaid-ts-mode.el ends here
