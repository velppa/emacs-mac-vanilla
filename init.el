;;; init.el --- Vanilla emacs-mac configuration. -*- lexical-binding: t; -*-

(setq vc-follow-symlinks t)

(require 'org)

(defun my-tangle-elisp-from-buffer (target)
  "Tangle all elisp source code blocks into TARGET file."
  (org-babel-tangle-file (buffer-file-name) target (rx (or "elisp" "elisp")))
  (byte-compile-file target))

(defmacro comment (&rest _)
  "Comment out one or more s-expressions."
  nil)

(setq native-comp-async-report-warnings-errors 'silent
      frame-resize-pixelwise t
      frame-title-format "Emacs Vanilla – %b")

;; (tool-bar-mode -1) ; it loves to be in init.el, not in early-init.el
(scroll-bar-mode -1)
(fringe-mode '(5 . 5))

;; enable .dir-locals.el
;; (add-to-list 'safe-local-variable-values
;; 	     '(org-roam-directory . (file-truename "~/Documents/Notes")))

(add-to-list 'safe-local-variable-values
	     '(org-roam-db-location . "~/.config/emacs/org-roam.db"))

(let ((f (file-truename (file-name-concat user-emacs-directory "custom.el"))))
  (setq custom-file f)
  (unless (file-exists-p f)
    (shell-command (format "touch \"%s\"" f)))
  (load custom-file))

(setq-default cursor-type 'bar)
;; (blink-cursor-mode 0)

(defun my-disable-all-themes (&rest _)
    (mapcar #'disable-theme custom-enabled-themes))

(advice-add 'load-theme :before 'my-disable-all-themes)

;; (global-so-long-mode 1)

(setq
  scroll-margin 0
  scroll-step 1
  next-line-add-newlines t
  visible-bell t
  scroll-conservatively 10000
  scroll-preserve-screen-position t
  mouse-wheel-follow-mouse t
  mouse-wheel-scroll-amount '(1 ((shift) . 1))
  require-final-newline t
  use-short-answers t
  tab-width 2
  large-file-warning-threshold 100000000)

(global-auto-revert-mode t)
(delete-selection-mode 1)

;; macOS-specific
(setq
 mac-command-modifier 'super
 mac-option-modifier 'meta
 mac-right-option-modifier 'hyper
 mac-control-modifier 'control
 mac-right-control-modifier 'control
 ns-use-native-fullscreen t
 select-enable-clipboard nil)

;; enabling some functions that are considered risky by default
(dolist (c '(narrow-to-region narrow-to-page upcase-region downcase-region))
  (put c 'disabled nil))

(setq-default line-spacing 0)

(defun variable-pitch-mode-on ()
  "Enable `variable-pitch-mode'."
  (variable-pitch-mode 1))

(defun variable-pitch-mode-off ()
  "Disable `variable-pitch-mode'."
  (variable-pitch-mode -1))

(add-hook 'text-mode-hook #'variable-pitch-mode-on)
(add-hook 'prog-mode-hook #'variable-pitch-mode-off)
(add-hook 'yaml-mode-hook #'variable-pitch-mode-off)

(defun my-set-fonts (fonts)
  "Set font using provided alists in FONTS."
  (let ((fixed (cdr (assoc 'fixed fonts)))
        (variable (cdr (assoc 'variable fonts))))
    (apply #'set-face-attribute 'default nil fixed)
    (apply #'set-face-attribute 'fixed-pitch nil fixed)
    (apply #'set-face-attribute 'variable-pitch nil variable)))

;; Setting font depending on the machine
(let ((host (system-name)))
  (cond
   ((equal host "mac-mini.local")
    (my-set-fonts
     '((fixed . (:family "PragmataPro" :height 180))
       (variable . (:family "Helvetica" :height 200)))))
   ((equal host "mini.home")
    (my-set-fonts
     '((fixed . (:family "PragmataPro" :height 190))
       (variable . (:family "Atkinson Hyperlegible" :height 240)))))
   ((equal host "m4pro")
    (my-set-fonts
     '((fixed . (:family "PragmataPro" :height 180))
       (variable .
                 (:family "Atkinson Hyperlegible Next" :height 230)))))
   (t (my-set-fonts
       '((fixed . (:family "PragmataPro" :height 180))
         (variable .
          ;; (:family "Atkinson Hyperlegible Next" :height 230)
          ;; (:family "Charter" :height 200)
          (:family "Helvetica" :height 200)))))))

;; see /Users/pavel/Agent/260324--eye-unicode-symbol/plan.org
;;(set-fontset-font t 'cyrillic (font-spec :family "Helvetica"))
(set-fontset-font t 'cyrillic (font-spec :family "Charter"))
;;(set-fontset-font t 'cyrillic (font-spec :family "Atkinson Hyperlegible"))
(set-fontset-font t 'symbol (font-spec :family "PragmataPro")) ;; to display unicode symbols properly

(setq make-backup-files nil)

(keymap-global-set "C-x C-f" #'find-file-at-point)

(use-package recentf
  :config
  (recentf-mode 1)
  (setq
   create-lockfiles nil
   recentf-max-menu-items 20
   recentf-max-saved-items 1000))

(defun my-open-file-in-external-app (file)
  "Opens FILE using `open` shell command."
  (interactive "fFile: ")
  (shell-command (format "open \"%s\"" (file-truename file))))

(defun delete-visited-file (buffer-name)
  "Delete the file visited by the buffer named BUFFER-NAME."
  (interactive "bDelete file visited by buffer ")
  (let* ((buffer (get-buffer buffer-name))
         (filename (buffer-file-name buffer)))
    (when buffer
      (when (and filename
                 (file-exists-p filename))
        (delete-file filename))
      (kill-buffer buffer))))

(defun find-file-as-root ()
  "Like `ido-find-file, but automatically edit the file with
root-privileges (using tramp/sudo), if the file is not writable by
user.
URL: https://emacs-fu.blogspot.com/2013/03/editing-with-root-privileges-once-more.html"
  (interactive)
  (let ((file (ido-read-file-name "Edit as root: ")))
    (unless (file-writable-p file)
      (setq file (concat "/sudo::" file)))
    (find-file file)))


(auto-save-mode 1)

;; (and buffer-auto-save-file-name (>= buffer-saved-size 0)) ;; t

(defun kill-buffer-dwim ()
  "Kills current buffer without prompt, with C-u it prompts for buffer to kill."
  (interactive)
  (if (equal current-prefix-arg nil)
    (kill-current-buffer)
    (call-interactively 'kill-buffer)))

(keymap-global-set "C-x k" #'kill-buffer-dwim)

(defun display-line-numbers-toggle ()
  "Toggle displaying line number in the buffer."
  (interactive)
  (if (eq display-line-numbers 'relative)
      (setq display-line-numbers 'absolute)
    (if (eq display-line-numbers 'absolute)
        (setq display-line-numbers nil)
      (setq display-line-numbers 'relative))))

(keymap-global-set "C-c N" #'display-line-numbers-toggle)

(add-hook 'before-save-hook #'delete-trailing-whitespace)
(setq-default indent-tabs-mode nil)
(setq sentence-end-double-space nil)

(setq project-vc-extra-root-markers '("go.mod" ".project"))

(comment
 (use-package ido
    :config
    (ido-mode 1)
    (setq ido-everywhere t
      ido-enable-flex-matching t)))

(use-package icomplete
  :config
    (fido-vertical-mode 1)
    ;; (icomplete-vertical-mode 1)
    )

(setq completion-auto-help 'visible
      completion-auto-select 'second-tab)

(setq completion-category-overrides
      '((buffer
         (styles initials flex)
         (cycle . 3))
        (default
         (styles basic flex initials)
         (cycle . 5))))

(setq completion-styles '(basic substring partial-completion flex))

(setq read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      completion-ignore-case t)

(use-package org
  :config
  (require 'org-tempo)
  (setq org-src-preserve-indentation t
        org-edit-src-content-indentation 0))

(use-package emacs
  :bind
  (
   ("C-x C-b" . ibuffer)
   ("s-1" . delete-other-windows)
   ("s-2" . split-window-below)
   ("s-3" . split-window-right)
   ("s-s" . save-buffer)
   ("s-a" . mark-whole-buffer)
   ("s-;" . comment-line)
   ("s-p" . backward-paragraph)
   ("s-n" . forward-paragraph)
   ("s-h" . previous-buffer)
   ("s-j" . switch-to-prev-buffer)
   ("s-k" . mode-line-other-buffer)
   ("s-l" . next-buffer)
   ("s-w" . delete-window)
   ("s-o" . tab-next)
   ("s-O" . tab-previous)
   ("s-b" . ido-switch-buffer)
   ("s-r" . recentf)
   ("H-l" . global-tab-line-mode)
   ("H-L" . tab-bar-mode)
   ("M-o" . other-window)
   ("<prior>" . backward-page)
   ("<next>" . forward-page)
   ("C-z" . repeat)
   ("s-v" . clipboard-yank)
   ("s-x" . clipboard-kill-ring)
   ("s-c" . clipboard-kill-ring-save)))

(use-package grep :ensure nil
  ;;; :commands (grep-find grep)
  :config
  (grep-apply-setting 'grep-find-command
        '("rg --vimgrep '' $(git rev-parse --show-toplevel || echo .)" . 15))
  (keymap-global-set "M-s g" #'grep-find)
  (keymap-set grep-mode-map "o" #'compile-goto-error))

(use-package js :ensure nil
  :config
  (setq js-indent-level 2))
