;;; early-init --- Code executed very early.
;;; Commentary:
;;; Code:
(message "Loading early-init.el")

;; (setq native-comp-speed -1)
;; (setq vc-follow-symlinks t)


;;; Uncomment these when installing fresh instance of Emacs.
;;(setq use-package-always-ensure t)
;;(setq use-package-always-defer t)

;; Use a hook so the message doesn't get clobbered by other messages.
(setq gc-cons-threshold most-positive-fixnum)

(add-hook
 'emacs-startup-hook
 (lambda ()
   (setq gc-cons-threshold (* 100 1000 1000))
   (setq gc-cons-percentage 0.6)
   ;; (setq gc-cons-threshold 800000)
   (message "Emacs ready in %.2f seconds with %d garbage collections."
            (float-time (time-subtract after-init-time before-init-time))
            gcs-done)))

;;; Loading Vanilla Emacs configuration
(let* ((early-init-dir (file-name-directory (or load-file-name buffer-file-name)))
       (init-file (expand-file-name "init.el" early-init-dir)))
  (when (file-exists-p init-file)
    (message "Loading %s" init-file)
    (load init-file)))

;;; early-init.el ends here.
