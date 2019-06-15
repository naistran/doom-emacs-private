;;; ~/.config/doom/config.el -*- lexical-binding: t; -*-

;; (defvar xdg-data (getenv "XDG_DATA_HOME"))
;; (defvar xdg-bin (getenv "XDG_BIN_HOME"))
;; (defvar xdg-cache (getenv "XDG_CACHE_HOME"))
;; (defvar xdg-config (getenv "XDG_CONFIG_HOME"))

(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))

(setq
 ;;       user-full-name "Henrik Lissner"
 ;;       user-mail-address "henrik@lissner.net"

 ;; Also install this for ligature support:
 ;; https://github.com/tonsky/FiraCode/files/412440/FiraCode-Regular-Symbol.zip
 doom-font (font-spec :family "Fira Code" :size 12)
 doom-variable-pitch-font (font-spec :family "Fira Code" :size 14)
 doom-big-font (font-spec :family "Fira Code" :size 19))

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

      (:leader
        (:prefix "f"
          "t" #'+hlissner/find-in-dotfiles
          "T" #'+hlissner/browse-dotfiles)
        (:prefix "n"
          "m" #'+hlissner/find-notes-for-major-mode
          "p" #'+hlissner/find-notes-for-project)

      ;; Quicker access to agenda
        "a" #'org-agenda)

      ;; Zen mode
      (:map evil-window-map
        "z" #'writeroom-mode)

      ;; Improve tag autocompletion
      (:after counsel
        [remap org-set-tags-command] #'counsel-org-tag))

;; evil-org-agenda has the wrong keybinding for "M"
(add-hook 'org-agenda-mode-hook
          (lambda ()
          (general-define-key
            :keymaps 'local
            :states 'motion
            "M" 'org-agenda-bulk-unmark-all)))


;;
;;; Modules

;; app/rss
(add-hook! 'elfeed-show-mode-hook (text-scale-set 2))

;; lang/org
(after! org
  (add-to-list 'org-modules 'org-habit t)
  (setq org-directory "~/org/"
        org-agenda-files (list org-directory)
        org-todo-keywords
        '((sequence "TODO(t!)" "STARTED(s!)" "|" "DONE(d!)")
          (sequence "NEXT(n!)" "WAITING(w!)" "LATER(l!)" "|" "CANCELLED(c!)"))
        org-todo-keyword-faces
        '(("WAITING" :inherit bold)
          ("LATER" :inherit (warning bold)))))
(setq org-ellipsis " ▶ "
      org-bullets-bullet-list '("#")
      ;; org-log-done 'time
      ;; org-fast-tag-selection-single-key t
      org-use-speed-commands t
      org-tag-persistent-alist
      '((:startgroup)
        ("HOME")
        ("RESEARCH")
        ("TEACHING")
        (:endgroup)
        (:startgroup)
        ("OS")
        ("DEV")
        ("WWW")
        (:endgroup)
        (:startgroup)
        ("EASY")
        ("MEDIUM")
        ("HARD")
        (:endgroup)
        ("URGENT")
        ("KEY")
        ("BONUS")
        ("noexport"))
      org-tag-faces
      '(("HOME" . (:foreground "GoldenRod" :weight bold))
        ("RESEARCH" . (:foreground "GoldenRod" :weight bold))
        ("TEACHING" . (:foreground "GoldenRod" :weight bold))
        ("OS" . (:foreground "IndianRed1" :weight bold))
        ("DEV" . (:foreground "IndianRed1" :weight bold))
        ("WWW" . (:foreground "IndianRed1" :weight bold))
        ("URGENT" . (:foreground "Red" :weight bold))
        ("KEY" . (:foreground "Red" :weight bold))
        ("EASY" . (:foreground "OrangeRed" :weight bold))
        ("MEDIUM" . (:foreground "OrangeRed" :weight bold))
        ("HARD" . (:foreground "OrangeRed" :weight bold))
        ("BONUS" . (:foreground "GoldenRod" :weight bold))
        ("noexport" . (:foreground "LimeGreen" :weight bold))))

;; company
;; Make autocomplete work with org (C-x C-o)
(defun add-pcomplete-to-capf ()
  (add-hook 'completion-at-point-functions 'pcomplete-completions-at-point nil t))
(add-hook 'org-mode-hook #'add-pcomplete-to-capf)
(global-company-mode)

;; visual-line-mode
;; Make text wrap
;; enable visual-line first
(global-visual-line-mode)
;; disable auto-fill because it automatically splits the line where we don't want
(remove-hook 'org-mode-hook #'auto-fill-mode)


;;
;;; Packages

;; org-brain
(def-package! org-brain
  :init
  (setq org-brain-path (expand-file-name "brain" org-directory))
  ;; For Evil users
  (with-eval-after-load 'evil
    (evil-set-initial-state 'org-brain-visualize-mode 'emacs))
  :config
  (setq org-id-track-globally t)
  (setq org-id-locations-file (expand-file-name ".org-id-locations" org-directory))
  (push '("b" "Brain" plain (function org-brain-goto-end)
          "* %i%?" :empty-lines 1)
        org-capture-templates)
  (setq org-brain-visualize-default-choices 'all)
  (setq org-brain-title-max-length 12))

;; org-super-agenda
(def-package! org-super-agenda
  :config
  (org-super-agenda-mode))
(setq org-super-agenda-header-map (make-sparse-keymap))
(setq org-agenda-custom-commands
      '(("c" "Super Agenda" agenda
         (org-super-agenda-mode)
         ((org-super-agenda-groups
           '(
             (:name "Next Items"
                    :time-grid t
                    :tag ("NEXT" "outbox"))
             (:name "Important"
                    :priority "A")
             (:name "Today"
                    :time-grid t
                    :scheduled today)
             (:priority<= "B"
                          :order 1)
             )))
         (org-agenda nil "a"))))

;; org-sticky-header
(def-package! org-sticky-header
  :config
  (setq org-sticky-header-full-path 'full))
(add-hook! 'org-mode-hook
  (org-sticky-header-mode))

;; deft
(def-package! deft
  :config
  (setq deft-directory org-brain-path))
  (setq deft-recursive t)


;;
;;; Custom

(def-project-mode! +javascript-screeps-mode
  :match "/screeps\\(?:-ai\\)?/.+$"
  :modes (+javascript-npm-mode)
  :add-hooks (+javascript|init-screeps-mode)
  :on-load (load! "lisp/screeps"))
