;;; ~/.config/doom/config.el -*- lexical-binding: t; -*-

;; (defvar xdg-data (getenv "XDG_DATA_HOME"))
;; (defvar xdg-bin (getenv "XDG_BIN_HOME"))
;; (defvar xdg-cache (getenv "XDG_CACHE_HOME"))
;; (defvar xdg-config (getenv "XDG_CONFIG_HOME"))

(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))

;; (setq user-full-name "Henrik Lissner"
;;       user-mail-address "henrik@lissner.net"

;;       doom-font (font-spec :family "Input Mono Narrow" :size 12)
;;       doom-variable-pitch-font (font-spec :family "Noto Sans" :size 14)
;;       doom-big-font (font-spec :family "Fira Mono" :size 19))


;;
;;; Host-specific config

(pcase (system-name)
  ("halimede"
   (font-put doom-font :size 9)) ; smaller display
  ("triton"
   ;; I've swapped these keys on my keyboard
   (setq x-super-keysym 'meta
         x-meta-keysym  'super)))

(when IS-LINUX
  (font-put doom-font :weight 'semi-light))
(when IS-MAC
  (setq ns-use-thin-smoothing t)
  (add-hook 'window-setup-hook #'toggle-frame-maximized))


;;
;;; Keybinds

(map! :m "M-j" '+hlissner:multi-next-line
      :m "M-k" '+hlissner:multi-previous-line

      ;; Easier window movement
      :n "C-h" 'evil-window-left
      :n "C-j" 'evil-window-down
      :n "C-k" 'evil-window-up
      :n "C-l" 'evil-window-right

      (:map evil-treemacs-state-map
        "C-h" 'evil-window-left
        "C-l" 'evil-window-right)

      (:when IS-LINUX
        "s-x" #'execute-extended-command
        "s-;" #'eval-expression
        ;; use super for window/frame navigation/manipulation
        "s-w" #'delete-window
        "s-W" #'delete-frame
        "s-n" #'+default/new-buffer
        "s-N" #'make-frame
        "s-q" (if (daemonp) #'delete-frame #'evil-quit-all)
        ;; Restore OS undo, save, copy, & paste keys (without cua-mode, because
        ;; it imposes some other functionality and overhead we don't need)
        "s-z" #'undo
        "s-c" (if (featurep 'evil) #'evil-yank #'copy-region-as-kill)
        "s-v" #'yank
        "s-s" #'save-buffer
        ;; Buffer-local font scaling
        "s-+" (λ! (text-scale-set 0))
        "s-=" #'text-scale-increase
        "s--" #'text-scale-decrease
        ;; Conventional text-editing keys
        "s-a" #'mark-whole-buffer
        :gi [s-return]    #'+default/newline-below
        :gi [s-S-return]  #'+default/newline-above
        :gi [s-backspace] #'doom/backward-kill-to-bol-and-indent)

      :leader
      (:prefix "f"
        "t" #'+hlissner/find-in-dotfiles
        "T" #'+hlissner/browse-dotfiles)
      (:prefix "n"
        "m" #'+hlissner/find-notes-for-major-mode
        "p" #'+hlissner/find-notes-for-project))


;;
;;; Modules

(setq +pretty-code-enabled-modes '(emacs-lisp-mode org-mode))

;; app/rss
(add-hook! 'elfeed-show-mode-hook (text-scale-set 2))

;; ;; emacs/eshell
;; (after! eshell
;;   (set-eshell-alias!
;;    "f"   "(other-window 1) && find-file $1"
;;    "l"   "ls -lh"
;;    "d"   "dired $1"
;;    "gl"  "(call-interactively 'magit-log-current)"
;;    "gs"  "magit-status"
;;    "gc"  "magit-commit"))

;; ;; tools/magit
;; (setq magit-repository-directories '(("~/work" . 2))
;;       magit-save-repository-buffers nil
;;       transient-values '((magit-commit "--gpg-sign=5F6C0EA160557395")
;;                          (magit-rebase "--autosquash" "--gpg-sign=5F6C0EA160557395")
;;                          (magit-pull "--rebase" "--gpg-sign=5F6C0EA160557395")))

;; lang/org
(after! org
  (add-to-list 'org-modules 'org-habit t)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "STARTED(s)" "|" "DONE(d)")
          (sequence "NEXT(n)" "WAITING(w)" "LATER(l)" "|" "CANCELLED(c)")
          (sequence "[ ](T)" "[-](p)" "[?](m)" "|" "[X](D)"))
        org-todo-keyword-faces
        '(("[-]" :inherit (font-lock-constant-face bold))
          ("[?]" :inherit (warning bold))
          ("WAITING" :inherit bold)
          ("LATER" :inherit (warning bold)))))
(setq org-ellipsis " ▶ "
      ;; The standard unicode characters are usually misaligned depending on the
      ;; font. This bugs me. Markdown #-marks for headlines are more elegant.
      org-bullets-bullet-list '("#")
      org-log-done 'time)


;;
;;; Custom

(def-project-mode! +javascript-screeps-mode
  :match "/screeps\\(?:-ai\\)?/.+$"
  :modes (+javascript-npm-mode)
  :add-hooks (+javascript|init-screeps-mode)
  :on-load (load! "lisp/screeps"))
