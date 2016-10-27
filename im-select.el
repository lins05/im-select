;; Based on https://gist.github.com/celadevra/7ae45920e2494fbc38ef

;; In your .emacs:
;;
;; (setq load-path (cons "/path/to/im-select" load-path))
;; (module-load "/path/to/im-select/im-select-module.so")
;; (require 'im-select)
;;

;; switch to English input method when switching to normal mode
;; and switch back when entering insert/replace modes
;; need external script support, currently mac-only
(defvar default-im "com.apple.keylayout.US" "Default ascii-only input method")
(defvar prev-im (osx-im-select)
 "IM that I use when starting Emacs and exiting insert mode")

(defun shoud-enable-im-select()
  (interactive)
  t)
  ;; (eq major-mode 'org-mode))

(defun im-use-english ()
  "Switch to English input method on a Mac. im-select is a tool
provided at http://git.io/ndA8Mw"
  (interactive)
  (when (shoud-enable-im-select)
    (cond ((eq system-type 'darwin)
           (osx-im-select default-im)))))

(defun im-remember ()
  "Remember the input method being used in insert mode,
so we can switch to it in other modes."
  (interactive)
  (when (shoud-enable-im-select)
    (cond ((eq system-type 'darwin)
           (setq prev-im (substring (shell-command-to-string "im-select") 0 -1))))))

(defun im-use-prev ()
  "Use previous input method.
If previous input method is not defined, use default method"
  (interactive)
  (when (shoud-enable-im-select)
    (cond ((eq system-type 'darwin)
           (if prev-im
               (osx-im-select prev-im)
             (osx-im-select default-im))))))

(add-hook 'evil-normal-state-entry-hook 'im-use-english)
(add-hook 'evil-insert-state-entry-hook 'im-use-prev)
(add-hook 'evil-insert-state-exit-hook 'im-remember)
(add-hook 'evil-replace-state-entry-hook 'im-use-prev)
(add-hook 'evil-replace-state-exit-hook 'im-remember)
(add-hook 'evil-emacs-state-entry-hook 'im-use-english)

;; (remove-hook 'evil-normal-state-entry-hook 'im-use-english)
;; (remove-hook 'evil-insert-state-entry-hook 'im-use-prev)
;; (remove-hook 'evil-insert-state-exit-hook 'im-remember)
;; (remove-hook 'evil-replace-state-entry-hook 'im-use-prev)
;; (remove-hook 'evil-replace-state-exit-hook 'im-remember)
;; (remove-hook 'evil-emacs-state-entry-hook 'im-use-english)

(provide 'im-select)
