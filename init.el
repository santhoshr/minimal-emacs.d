;;; init.el --- Init -*- no-byte-compile: t; lexical-binding: t; -*-

;; Author: James Cherti
;; URL: https://github.com/jamescherti/minimal-emacs.d
;; Package-Requires: ((emacs "29.1"))
;; Keywords: maint
;; Version: 1.0.1
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;; This is the main initialization file for Emacs. It configures package
;; archives, ensures essential packages like `use-package` are installed, and
;; sets up further package management and customization settings.

;;; Code:

;;; Load pre-init.el
(minimal-emacs-load-user-init "pre-init.el")

;;; package.el

(require 'package)

(when (version< emacs-version "28")
  (add-to-list 'package-archives
               '("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(customize-set-variable 'package-archive-priorities
                        '(("gnu"    . 99)
                          ("nongnu" . 80)
                          ("stable" . 70)
                          ("melpa"  . 0)))

(when package-enable-at-startup
  (package-initialize)
  (unless package-archive-contents
    (package-refresh-contents t)))

;;; use-package
;; Load use-package for package configuration

;; Ensure the 'use-package' package is installed and loaded
(unless (package-installed-p 'use-package)
  (package-refresh-contents t)
  (package-install 'use-package)
  (eval-when-compile
    (require 'use-package)))

(eval-when-compile
  (require 'use-package))

;;; Misc
(setq enable-recursive-minibuffers t)
(setq custom-file
      (expand-file-name "custom.el"
                        minimal-emacs--default-user-emacs-directory))

;; switch-to-buffer runs pop-to-buffer-same-window instead
(setq switch-to-buffer-obey-display-actions t)

;;; Files

;; Disable the warning "X and Y are the same file". Ignoring this warning is
;; acceptable since it will redirect you to the existing buffer regardless.
(setq find-file-suppress-same-file-warnings t)

;; Resolve symlinks when opening files, so that any operations are conducted
;; from the file's true directory (like `find-file').
(setq find-file-visit-truename t
      vc-follow-symlinks t)

;;; Backup files

;; Avoid generating backups or lockfiles to prevent creating world-readable
;; copies of files.
(setq create-lockfiles nil)
(setq make-backup-files nil)

(setq backup-directory-alist
      `(("." . ,(expand-file-name "backup" user-emacs-directory))))
(setq tramp-backup-directory-alist backup-directory-alist)
(setq backup-by-copying-when-linked t)
(setq backup-by-copying t)  ; Backup by copying rather renaming
(setq delete-old-versions t)  ; Delete excess backup versions silently
(setq version-control t)  ; Use version numbers for backup files
(setq kept-new-versions 5)
(setq kept-old-versions 5)
(setq vc-make-backup-files nil)  ; Do not backup version controlled files

;;; Auto save
;; Enable auto-save to safeguard against crashes or data loss. The
;; `recover-file' or `recover-session' functions can be used to restore
;; auto-saved data.
(setq auto-save-default t)

;; Do not auto-disable auto-save after deleting large chunks of text. The
;; purpose of auto-save is to provide a failsafe, and disabling it contradicts
;; this objective.
(setq auto-save-include-big-deletions t)

(setq auto-save-list-file-prefix
      (expand-file-name "autosave/" user-emacs-directory))
(setq tramp-auto-save-directory
      (expand-file-name "tramp-autosave/" user-emacs-directory))

;; Auto save options
(setq kill-buffer-delete-auto-save-files t)

;;; Subr
;; Allow for shorter responses: "y" for yes and "n" for no.
(setq use-short-answers t)
(defalias #'yes-or-no-p 'y-or-n-p)
(defalias #'view-hello-file #'ignore)  ; Never show the hello file

;;; Mule-util
(setq truncate-string-ellipsis "…")

;;; Frames and windows
(setq frame-title-format '("%b – Emacs")
      icon-title-format frame-title-format)

;; Resizing the Emacs frame can be costly when changing the font. Disable this
;; to improve startup times with fonts larger than the system default.
(setq frame-resize-pixelwise t)

;; However, do not resize windows pixelwise, as this can cause crashes in some
;; cases when resizing too many windows at once or rapidly.
(setq window-resize-pixelwise nil)

(setq resize-mini-windows 'grow-only)

;;; Buffer
(setq-default left-fringe-width  8)
(setq-default right-fringe-width 8)

;; Do not show an arrow at the top/bottomin the fringe and empty lines
(setq-default indicate-buffer-boundaries nil)
(setq-default indicate-empty-lines nil)

(setq-default word-wrap t)

;;; Smooth scrolling
;; Enables faster scrolling through unfontified regions. This may result in
;; brief periods of inaccurate syntax highlighting immediately after scrolling,
;; which should quickly self-correct.
(setq fast-but-imprecise-scrolling t)

(setq hscroll-margin 2
      hscroll-step 1
      ;; Emacs spends excessive time recentering the screen when the cursor
      ;; moves more than N lines past the window edges (where N is the value of
      ;; `scroll-conservatively`). This can be particularly slow in larger files
      ;; during extensive scrolling. If `scroll-conservatively` is set above
      ;; 100, the window is never automatically recentered. The default value of
      ;; 0 triggers recentering too aggressively. Setting it to 10 reduces
      ;; excessive recentering and only recenters the window when scrolling
      ;; significantly off-screen.
      scroll-conservatively 10
      scroll-margin 0
      scroll-preserve-screen-position t
      ;; Minimize cursor lag slightly by preventing automatic adjustment of
      ;; `window-vscroll' for tall lines.
      auto-window-vscroll nil
      ;; Mouse
      mouse-wheel-scroll-amount '(2 ((shift) . hscroll))
      mouse-wheel-scroll-amount-horizontal 2)

;;; Cursor
;; The blinking cursor is distracting and interferes with cursor settings in
;; some minor modes that try to change it buffer-locally (e.g., Treemacs).
;; Additionally, it can cause freezing, especially on macOS, for users with
;; customized and colored cursors.
(blink-cursor-mode -1)

;; Don't blink the paren matching the one at point, it's too distracting.
(setq blink-matching-paren nil)

;; Don't stretch the cursor to fit wide characters, it is disorienting,
;; especially for tabs.
(setq x-stretch-cursor nil)

;;; Annoyances

;; No beeping or blinking
(setq visible-bell nil)
(setq ring-bell-function #'ignore)

;;; Load post-init.el
(minimal-emacs-load-user-init "post-init.el")

(provide 'init)

;;; init.el ends here
