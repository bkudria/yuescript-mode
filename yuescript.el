;;; yuescript.el --- Major mode for editing YueScript code
;;;
;; Author: @GriffinSchneider, @k2052, @EmacsFodder, @bkudria
;; Version: 20241020-0.1.0
;; Package-Requires: ((cl-lib "0.5") (emacs "24"))
;;; Commentary:
;;
;; A basic major mode for editing YueScript, a preprocessed language
;; for Lua which shares many similarities with CoffeeScript.
;;
;;; License: MIT Licence
;;
;;; Code:

(require 'cl-lib)

(defgroup yuescript nil
  "YueScript (for Lua) language support for Emacs."
  :tag "YueScript"
  :group 'languages)

(defcustom yuescript-indent-offset 2
  "How many spaces to indent YueScript code per level of nesting."
  :group 'yuescript
  :type 'integer
  :safe 'integerp)

(defcustom yuescript-comment-start "-- "
  "Default value of `comment-start'."
  :group 'yuescript
  :type 'string
  :safe 'stringp)

(defvar yuescript-statement
  '("return" "break" "continue"))

(defvar yuescript-repeat
  '("for" "while"))

(defvar yuescript-conditional
  '("if" "else" "elseif" "then" "switch" "when" "unless"))

(defvar yuescript-keyword
  '("export" "local" "import" "from" "with" "in" "and" "or" "not"
    "class" "extends" "super" "using" "do"))

(defvar yuescript-keywords
  (append yuescript-statement yuescript-repeat yuescript-conditional yuescript-keyword))

(defvar yuescript-constants
  '("nil" "true" "false" "self"))

(defvar yuescript-keywords-regex (regexp-opt yuescript-keywords 'symbols))

(defvar yuescript-constants-regex (regexp-opt yuescript-constants 'symbols))

(defvar yuescript-class-name-regex "\\<[A-Z]\\w*\\>")

(defvar yuescript-function-keywords
  '("->" "=>" "(" ")" "[" "]" "{" "}"))
(defvar yuescript-function-regex (regexp-opt yuescript-function-keywords))

(defvar yuescript-octal-number-regex
  "\\_<0x[[:xdigit:]]+\\_>")

(defvar yuescript-table-key-regex
  "\\_<\\w+:")

(defvar yuescript-ivar-regex
  "@\\_<\\w+\\_>")

(defvar yuescript-assignment-regex
  "\\([-+/*%]\\|\\.\\.\\)?=")

(defvar yuescript-number-regex
  (mapconcat 'identity '("[0-9]+\\.[0-9]*" "[0-9]*\\.[0-9]+" "[0-9]+") "\\|"))

(defvar yuescript-assignment-var-regex
  (concat "\\(\\_<\\w+\\) = "))

(defvar yuescript-font-lock-defaults
  `((,yuescript-class-name-regex     . font-lock-type-face)
    (,yuescript-function-regex       . font-lock-function-name-face)
    (,yuescript-assignment-regex     . font-lock-preprocessor-face)
    (,yuescript-constants-regex      . font-lock-constant-face)
    (,yuescript-keywords-regex       . font-lock-keyword-face)
    (,yuescript-ivar-regex           . font-lock-variable-name-face)
    (,yuescript-assignment-var-regex . (1 font-lock-variable-name-face))
    (,yuescript-octal-number-regex   . font-lock-constant-face)
    (,yuescript-number-regex         . font-lock-constant-face)
    (,yuescript-table-key-regex      . font-lock-variable-name-face)
    ("!"                              . font-lock-warning-face)))

(defun yuescript-indent-level (&optional blankval)
  "Return nesting depth of current line.

If BLANKVAL is non-nil, return that instead if the line is blank.
Upon return, regexp match data is set to the leading whitespace."
  (cl-assert (= (point) (point-at-bol)))
  (looking-at "^[ \t]*")
  (if (and blankval (= (match-end 0) (point-at-eol)))
      blankval
    (floor (/ (- (match-end 0) (match-beginning 0))
              yuescript-indent-offset))))

(defun yuescript-indent-line ()
  "Cycle indentation levels for the current line of YueScript code.

Looks at how deeply the previous non-blank line is nested. The
maximum indentation level for the current line is that level plus
one.

When computing indentation depth, one tab is currently considered
equal to one space. Tabs are currently replaced with spaces when
re-indenting a line."
  (goto-char (point-at-bol))
  (let ((curlinestart (point))
        (prevlineindent -1))
    ;; Find indent level of previous non-blank line.
    (while (and (< prevlineindent 0) (> (point) (point-min)))
      (goto-char (1- (point)))
      (goto-char (point-at-bol))
      (setq prevlineindent (yuescript-indent-level -1)))
    ;; Re-indent current line based on what we know.
    (goto-char curlinestart)
    (let* ((oldindent (yuescript-indent-level))
           (newindent (if (= oldindent 0) (1+ prevlineindent)
                        (1- oldindent))))
      (replace-match (make-string (* newindent yuescript-indent-offset)
                                  ? )))))

;;;###autoload
(define-derived-mode yuescript-mode prog-mode "YueScript"
  "Major mode for editing YueScript code."
  (setq font-lock-defaults '(yuescript-font-lock-defaults))
  (set (make-local-variable 'indent-line-function) 'yuescript-indent-line)
  (set (make-local-variable 'electric-indent-inhibit) t)
  (set (make-local-variable 'comment-start) yuescript-comment-start)
  (modify-syntax-entry ?\- ". 12b" yuescript-mode-syntax-table)
  (modify-syntax-entry ?\n "> b" yuescript-mode-syntax-table)
  (modify-syntax-entry ?\_ "w" yuescript-mode-syntax-table))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.yue\\'" . yuescript-mode))

(provide 'yuescript)

;;; yuescript.el ends here
