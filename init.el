(setq vc-follow-symlinks t)

(require 'org)

(defun my-tangle-elisp-from-buffer (target)
  "Tangle all emacs-lisp source code blocks into TARGET file."
  (org-babel-tangle-file (buffer-file-name) target "emacs-lisp"))

(defmacro comment (&rest body)
  "Comment out one or more s-expressions."
  nil)

(setq native-comp-async-report-warnings-errors 'silent)

;; (tool-bar-mode -1) ; it loves to be in init.el, not in early-init.el
(scroll-bar-mode -1)
(fringe-mode '(5 . 5))
(setq frame-resize-pixelwise t)
(setq frame-title-format "Emacs Vanilla – %b")

;; enable .dir-locals.el
;; (add-to-list 'safe-local-variable-values
;; 	     '(org-roam-directory . (file-truename "~/Documents/Notes")))

(add-to-list 'safe-local-variable-values
	     '(org-roam-db-location . "~/.config/emacs/org-roam.db"))

(let ((f (file-name-concat user-emacs-directory "custom.el")))
  (setq custom-file f)
  (unless (file-exists-p f)
    (shell-command (format "touch \"%s\"" f)))
  (load custom-file))

(setq-default cursor-type 'bar)
;; (blink-cursor-mode 0)

(define-key (current-global-map) (kbd "H-l") #'global-tab-line-mode)
(define-key (current-global-map) (kbd "H-L") #'tab-bar-mode)

(defun my-disable-all-themes (&rest _)
    (mapcar #'disable-theme custom-enabled-themes))

(advice-add 'load-theme :before 'my-disable-all-themes)

(setq
 mac-command-modifier 'super
 mac-option-modifier 'meta
 mac-right-option-modifier 'hyper
 mac-control-modifier 'control
 mac-right-control-modifier 'control
 ns-use-native-fullscreen t)

;;(global-so-long-mode 1)

(setq
  scroll-margin 0
  scroll-step 1
  next-line-add-newlines t
  visible-bell t
  scroll-conservatively 10000
  scroll-preserve-screen-position t
  mouse-wheel-follow-mouse t
  mouse-wheel-scroll-amount '(1 ((shift) . 1))
  require-final-newline t)

(setq-default
  auto-save-default nil
  make-backup-files nil
  delete-by-moving-to-trash t
  indent-tabs-mode nil
  inhibit-startup-message nil
  inhibit-startup-screen nil
  cursor-in-non-selected-windows nil
  echo-keystrokes 0.01
  help-window-select t
  large-file-warning-threshold 10000000
  use-short-answers t
  next-error-message-highlight t
  recenter-positions '(top middle bottom))

(global-auto-revert-mode t)
(delete-selection-mode 1)

(dolist (c '(narrow-to-region narrow-to-page upcase-region downcase-region))
  (put c 'disabled nil))

(setq-default line-spacing 0)
(set-fontset-font "fontset-default" 'cyrillic "Helvetica")

(require 'subr-x)

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

(cond
 ((equal (string-trim (shell-command-to-string "hostname")) "mac-mini.local")
  (my-set-fonts
   '((fixed . (:family "PragmataPro" :height 180))
     (variable . (:family "Helvetica" :height 200)))))
 (t (my-set-fonts
     '((fixed . (:family "PragmataPro" :height 160))
       (variable . ;; (:family "Atkinson Hyperlegible" :height 190)
                 (:family "Charter" :height 190))))))

(define-key (current-global-map) (kbd "C-x C-f") 'find-file-at-point)

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

(setq project-vc-extra-root-markers '("go.mod" ".project"))

(ido-mode -1)
(setq ido-everywhere t
      ido-enable-flex-matching t)

(fido-vertical-mode -1)

(setq completion-auto-help 'visible
      completion-auto-select 'second-tab)

(setq completion-category-overrides
      '((buffer
         (styles initials flex)
         (cycle . 3))
        (default
         (styles basic flex initials)
         (cycle . 5))))

(setq completion-styles
      '(basic substring partial-completion flex)
      ;; '(substring partial-completion flex) ;; it will be configured with orderless
      )

(setq read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      completion-ignore-case t)

(use-package org
  :config
  (require 'org-tempo)
  (setq org-src-preserve-indentation t
        org-edit-src-content-indentation 0))

(define-key isearch-mode-map (kbd "C-;") #'avy-isearch)

(mapc (lambda (kv) (define-key (current-global-map) (kbd (car kv)) (cadr kv)))
      (list
       '("s-1" delete-other-windows)
       '("s-2" split-window-below)
       '("s-3" split-window-right)
       '("s-s" save-buffer)
       '("s-a" mark-whole-buffer)
       '("s-;" comment-line)
       '("s-p" backward-paragraph)
       '("s-n" forward-paragraph)
       '("s-h" (lambda () (interactive) (other-window -1)))
       '("s-j" previous-buffer)
       '("s-k" next-buffer)
       '("s-l" other-window)
       '("s-w" delete-window)
       '("s-o" tab-next)
       '("s-O" tab-previous)
       '("s-b" ido-switch-buffer)
       '("s-r" recentf)
       '("H-l" global-tab-line-mode)
       '("H-L" tab-bar-mode)
       '("M-i" imenu)
       '("<prior>" backward-page)
       '("<next>" forward-page)
       '("s-v" clipboard-yank)
       '("s-x" clipboard-kill-ring)
       '("s-c" clipboard-kill-ring-save)
       ))

(use-package grep
  ;;; :commands (grep-find grep)
  :config
  (grep-apply-setting 'grep-find-command
        '("rg --vimgrep '' $(git rev-parse --show-toplevel || echo .)" . 15))
  (define-key (current-global-map) (kbd "M-s g") #'grep-find)
  (define-key grep-mode-map (kbd "o") #'compile-goto-error))