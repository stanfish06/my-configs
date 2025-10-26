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
(display-line-numbers-mode)
(setq display-line-numbers-type 'relative)

;; malpa
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(package-initialize)
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
(dolist (lang '(python javascript typescript tsx rust json yaml bash))
  (unless (treesit-language-available-p lang)
    (treesit-install-language-grammar lang)))

;; official packages
;; Enable Evil
(require 'evil)
(evil-mode 1)

;; indent lines
(use-package indent-bars
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

;; LSP
(require 'lsp-mode)
(add-hook 'python-mode-hook #'lsp)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(dash drag-stuff evil indent-bars lsp-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
