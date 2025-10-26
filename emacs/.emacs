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

(use-package tree-sitter
  :ensure t)
(use-package tree-sitter-langs
  :ensure t)
(require 'tree-sitter)
(require 'tree-sitter-langs)
(global-tree-sitter-mode)

;; official packages
;; Enable Evil
(require 'evil)
(evil-mode 1)

;; indent lines
(use-package indent-bars
  :custom
  ;; Set a single color for all bars
  (indent-bars-color '("#4E4E4E"))
  
  ;; Disable depth-based coloring so all bars are the same color
  (indent-bars-color-by-depth nil)
  
  ;; Optional: Simple pattern for a solid line
  (indent-bars-pattern ".")
  
  ;; Optional: Disable current depth highlighting if you want all bars identical
  (indent-bars-highlight-current-depth nil)
  
  ;; Enable for your languages/modes
  :hook ((python-mode
          emacs-lisp-mode
          js-mode
          typescript-mode
          ;; add other modes as needed
          ) . indent-bars-mode))

;; LSP
(require 'lsp-mode)
(add-hook 'python-mode-hook #'lsp)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(drag-stuff evil indent-bars lsp-mode tree-sitter tree-sitter-langs)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
