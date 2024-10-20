;;; yuescript-repl.el --- Major mode to interact with YueScript REPL
;;
;; Author: @GriffinSchneider, @k2052, @EmacsFodder
;; Version: 20140803-0.1.0
;;
;;; Commentary:
;;
;;  A basic major mode for YueScript REPL
;;
;;; License: MIT Licence
;;
;;; Code:

(require 'yuescript)

(define-derived-mode yuescript-repl-mode comint-mode "YueScript REPL"
  "Major mode to interact with a YueScript REPL.

See https://github.com/leafo/yuescript/wiki/Yuescriptrepl"
  (set-syntax-table yuescript-mode-syntax-table)
  (setq font-lock-defaults '(yuescript-font-lock-defaults)))

(provide 'yuescript-repl)

;;; yuescript-repl.el ends here
