;; Melpa Package Manager
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; set initial window size/position
(set-frame-size (selected-frame) 110 65)
(set-frame-position (selected-frame) 280 180)

;; auto uncompress .gz/.bz files
(auto-compression-mode 1)

;; font/color settings
(setq font-lock-maximum-decoration t)
(set-mouse-color "red")
(set-cursor-color "red")

;; delete highlighted text when start typing
(delete-selection-mode t)

;; highlight matching paren when cursor is over one
(require 'paren)
(show-paren-mode 1)

;disable auto-backup
(setq make-backup-files nil)

(setq minibuffer-max-depth nil)

;; forces line numbers to be displayed on mode line as well
(line-number-mode t)
(column-number-mode t)

;; Don't prompt when opening large files.
(setq large-file-warning-threshold nil)

;; disable the tool bar
(tool-bar-mode -1)

;; don't show whitespace in perl mode
(setq cperl-invalid-face 'default)

;; clean these up
(setq auto-save-interval 900)
(setq default-major-mode 'text-mode)
(setq initial-major-mode 'text-mode)
(setq scroll-step 1)
(put 'eval-expression 'disabled nil)




;; user defined functions

(defun backward-kill-line (arg)
  "Kill ARG lines backward."
  (interactive "p")
  (kill-line (- 1 arg)))


(defun display-current-function ()
  ;;"display current function the point is in. store the name in C-n register"
  (interactive)
  (let (func-name)
    (setq func-name (add-log-current-defun))
    (set-register ?\C-n func-name)
    (message (format "func-name: %s" func-name))
    )
  )

(defun my-c-mode-common-hook ()
  (c-set-style "Stroustrup")           ;; This seems closest to mine
  (c-toggle-auto-hungry-state 1)
  (c-toggle-auto-state -1)
  (setq c-basic-offset 4)
  (setq tab-width 4)
  (setq current-column "0")

  (setq-default indent-tabs-mode nil)
  ;;(setq-default indent-tabs-mode t)
  )

(defun set-window-name ()
  (interactive)
  (setq window_name (read-string "Window name: "))
  (modify-frame-parameters (selected-frame)
                           (list (cons 'name window_name)))
  )

(defun indent-or-expand (arg)
  "Either indent according to mode, or expand the word preceding point."
  (interactive "*P")
  (if (and
       (or (bobp) (= ?w (char-syntax (char-before))))
       (or (eobp) (not (= ?w (char-syntax (char-after))))))
      (dabbrev-expand arg)
    (indent-according-to-mode)))


(defun my-tab-fix ()
  (local-set-key [tab] 'indent-or-expand))



;; mode specific hooks

;; Delete trailing whitespace before saving (only in python mode)
(add-hook 'python-mode-hook
	  (lambda () (add-hook 'before-save-hook 'delete-trailing-whitespace)))

;; disable auto-fill for yaml mode
(add-hook 'yaml-mode
	  (lambda () (auto-fill-mode 0)))

;; c hooks
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
(add-hook 'c-mode-common-hook
          (lambda ()
            (c-set-offset 'case-label '+)))

;; tab hooks
(add-hook 'c-mode-hook          'my-tab-fix)
(add-hook 'sh-mode-hook         'my-tab-fix)
(add-hook 'emacs-lisp-mode-hook 'my-tab-fix)
(add-hook 'python-mode-hook     'my-tab-fix)


;; add sphinx-doc mode in python mode
(add-hook 'python-mode-hook
	  (lambda ()
	    (require 'sphinx-doc)
	    (sphinx-doc-mode t)))


;; clean this up
(setq auto-mode-alist (append '(("\\.flx$" . lisp-mode)
                                ("\\.lsp$" . lisp-mode)
                                ("\\.emacs*" . lisp-mode)
                                ("\\.cpp$" . c++-mode)
                                ("\\.hpp$" . c++-mode)
                                ("\\.pl$" . perl-mode)
                                ("\\.c$" . c-mode)
                                ("\\.h$"  . c-mode)
                                ("\\.tdl" .c-mode)
				;;("\\.php$" . php-mode)
                                ("[Mm]ake*" . makefile-mode)
                                ("Imakefile*" . makefile-mode)
                                ("\\.mk$" . makefile-mode)
				("\\.*aliases" . shell-script-mode)
                                ("\\.txt$" . text-mode))
                              auto-mode-alist))


;; macros

(fset 'log-annotate
   [return return return up up ?\[ ?J ?D ?D ?\] ? ])



;; cscope config

(setq  cscope_path
  (concat
    (getenv "WS_ROOT")
    (getenv "WS_PACKAGE")
  )
)

(set-variable 'cscope-use-relative-paths cscope_path)
(set-variable 'cscope-database-file (concat cscope_path "cscope.out"))
(setq cscope-database-regexps
`(
  ("^/"
   (,cscope_path))))


;; auto-complete config
(require 'completion)

;; smart-shift config
(require 'smart-shift)
(global-smart-shift-mode 1)

;; elpy config

(elpy-enable)

(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode 'flycheck-mode))


;;Ivy config

(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")



;; key mappings


(define-key global-map [end] 'end-of-line)
(define-key global-map [home] 'beginning-of-line)
(define-key global-map "\C-z" 'undo)
(define-key global-map "\C-b" 'backward-kill-line)
(define-key global-map "\eg" 'goto-line)
(define-key global-map [(meta insert)] 'insert-selection)
(define-key global-map [(meta delete)] 'backward-kill-word)

(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)
(global-set-key [f4] 'log-annotate)
(global-set-key [f5] 'revert-buffer)
(global-set-key [f7] 'other-window)
(global-set-key [f11] 'comment-region)


(global-set-key "\C-xx" 'bury-buffer)


(define-key global-map
      [menu-bar tools set-window-name]
      '("Set Window Name". set-window-name))


(global-set-key "f" 'display-current-function)

(define-key global-map [del] 'delete-char)
(define-key global-map "\C-z" 'undo)

;;(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "<f6>") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-ag)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(define-key read-expression-map (kbd "C-r") 'counsel-expression-history)

(global-set-key (kbd "C-x g") 'magit-status)

(global-set-key [f3] 'cscope-find-this-symbol)
(global-set-key [f2] 'cscope-find-global-definition)
(define-key isearch-mode-map "\C-f" 'isearch-yank-word-or-char)



(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Inconsolata" :foundry "unknown" :slant normal :weight normal :height 79 :width normal)))))
(put 'erase-buffer 'disabled nil)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(cperl-close-paren-offset -4)
 '(cperl-continued-statement-offset 4)
 '(cperl-indent-level 4)
 '(cperl-indent-parens-as-block t)
 '(cperl-tab-always-indent t)
 '(elpy-modules
   (quote
    (elpy-module-company elpy-module-eldoc elpy-module-pyvenv elpy-module-highlight-indentation elpy-module-yasnippet elpy-module-django elpy-module-sane-defaults)))
 '(inhibit-startup-screen t)
 '(load-home-init-file t t)
 '(package-selected-packages
   (quote
    (yaml-mode smart-shift web-mode jinja2-mode magit xcscope sphinx-doc hydra elpy counsel)))
 '(show-paren-mode t)
 '(tool-bar-mode nil))
