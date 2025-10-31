;; malpa
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; suppress docstring warnings from magit and lsp
(setq byte-compile-warnings '(not docstrings))

;; magit
(use-package magit
  :ensure t)
(require 'magit)

;; remove some ui components
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)

;; cursor
(setq-default cursor-type 'box)
(blink-cursor-mode 0)

;; theme
(load-theme 'myDarkTheme t)
(setq-default line-spacing nil)

;; line number
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

;; eshell

;; org
(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-star 'replace
        org-modern-table-vertical 1
        org-modern-table-horizontal 0.2
        org-modern-list '((43 . "➤")
                          (45 . "–")
                          (42 . "•"))
        org-modern-block-fringe nil
        org-modern-keyword nil
        org-modern-checkbox '((?X . "☑")
                              (?- . "❍")
                              (?\s . "☐"))
        org-modern-todo-faces '(("TODO" . (:foreground "orange" :weight bold))
                                ("DONE" . (:foreground "green" :weight bold)))))

;; navigation
(use-package vertico
  :ensure t
  :init (vertico-mode)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("C-u" . vertico-scroll-down)
              ("C-d" . vertico-scroll-up)))
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))
(use-package consult
  :ensure t
  :bind (("C-x b" . consult-buffer)
         ("C-x C-r" . consult-recent-file)
         ("C-c g" . consult-grep)         
         ("C-c f" . consult-find)         
         ("C-s" . consult-line)))         
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

;; melpa packages
(use-package drag-stuff
  :ensure t
  :bind (("C-S-<up>" . drag-stuff-up)
	 ("C-S-<down>" . drag-stuff-down)))

;; treesitter is built in after v29
;; make sure those grammer repos versions support currently installed treesitter
(use-package treesit
  :ensure nil
  :config
    (setq treesit-language-source-alist
	'((python "https://github.com/tree-sitter/tree-sitter-python" "v0.20.4")
	    (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "v0.20.1")
	    (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "typescript/src")
	    (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "tsx/src")
	    (rust "https://github.com/tree-sitter/tree-sitter-rust" "v0.20.4")
	    (json "https://github.com/tree-sitter/tree-sitter-json" "v0.20.1")
	    (yaml "https://github.com/ikatyang/tree-sitter-yaml" "v0.5.0")
	    (bash "https://github.com/tree-sitter/tree-sitter-bash" "v0.20.4")
	    (c "https://github.com/tree-sitter/tree-sitter-c" "v0.20.6")
	    (cpp "https://github.com/tree-sitter/tree-sitter-cpp" "v0.20.3")
	    (css "https://github.com/tree-sitter/tree-sitter-css" "v0.20.0")
	    (go "https://github.com/tree-sitter/tree-sitter-go" "v0.20.0")
	    (html "https://github.com/tree-sitter/tree-sitter-html" "v0.20.0"))))

;; auto install treesitter grammers
(dolist (lang '(python javascript typescript tsx rust json yaml bash go))
  (unless (treesit-language-available-p lang)
    (treesit-install-language-grammar lang)))

;; official packages
;; LSP
(use-package lsp-mode
  :ensure t)
(require 'lsp-mode)
(add-hook 'python-mode-hook #'lsp)
(use-package eglot
  :ensure t
  :hook ((python-mode python-ts-mode) . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
    `((python-ts-mode python-mode) . ("pyrefly" "lsp"))))
;; formatter
(use-package go-mode
  :ensure t
  :hook ((go-mode . lsp)
	 (before-save . gofmt-before-save)))

;; Enable Evil
(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))
(use-package lsp-ui
  :ensure t
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-show-with-cursor nil
        lsp-ui-doc-position 'at-point)
  (define-key lsp-ui-mode-map (kbd "K") 'lsp-ui-doc-glance))
(setq evil-want-keybinding nil) 
(setq evil-want-C-u-scroll t) 
(require 'evil)
(evil-mode 1)
(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init))
(with-eval-after-load 'evil
  (add-hook 'lsp-mode-hook
    (lambda ()
      (evil-local-set-key 'normal (kbd "K") 'lsp-ui-doc-glance))))

;; indent lines
(use-package indent-bars
  :ensure t
  :custom
  (indent-bars-color '("#4E4E4E"))
  (indent-bars-color-by-depth nil)
  (indent-bars-pattern ".")
  (indent-bars-highlight-current-depth nil)
  :hook ((python-mode
          emacs-lisp-mode
          js-mode
          typescript-mode
          ) . indent-bars-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(dash drag-stuff evil evil-collection go-mode indent-bars lsp-mode
	  lsp-ui org-modern)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
