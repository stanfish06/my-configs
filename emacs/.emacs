;; Note: delete ~/.emacs.elc if emacs warns that .emacs is newer
;; comment M-;
;; zoom window in and out: 1. enable winner mode. 2. focus on one window and C-x 1. 3. C-c left to undo deletion
;; Use auto-revert-mode to auto-load up-to-date file
;; use elisp-autofmt to format this file
;; for some reasons, evil / + C-r " does not paste text from registry to the search command. Just use emacs C-s and C-y
;; to search marked text, first copy it with C-Spc then M-w or yank, then C-s to search and C-y to paste
;; to set mark, press C-SPC twice (mark + selection then deselect). to set bookmark (similar to mark in vim)
;; in find-file, use M-RET to by-pass consult and use the exact file name typed

;; some useful keymaps
(keymap-global-set "C-c k" 'kill-current-buffer)
(keymap-global-set "C-c r" 'query-replace)

;; malpa
(require 'package)
(add-to-list
 'package-archives '("melpa" . "https://melpa.org/packages/")
 t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; suppress docstring warnings from magit and lsp
(setq byte-compile-warnings '(not docstrings))

;; magit
(use-package magit :ensure t)
(require 'magit)

;; snippet
(require 'yasnippet)
(yas-global-mode 1)
(keymap-global-set "C-c s r" 'yas-reload-all)
(keymap-global-set "C-c s n" 'yas-new-snippet)
(keymap-global-set "C-c s v" 'yas-visit-snippet-file)
(setq yas-snippet-dirs '("~/.emacs.d/emacs-tools/snippets"))

;; git gutter
(use-package
 git-gutter
 :ensure t
 :hook ((prog-mode org-mode) . git-gutter-mode)
 :config (setq git-gutter:update-interval 0.02))
(use-package
 git-gutter-fringe
 :ensure t
 :config
 (define-fringe-bitmap 'git-gutter-fr:added [224]
   nil
   nil
   '(center repeated))
 (define-fringe-bitmap 'git-gutter-fr:modified [224]
   nil
   nil
   '(center repeated))
 (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240]
   nil nil 'bottom))

;; remove some ui components
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(global-tab-line-mode 1)
(setq-default project-mode-line t)
(setq-default tab-width 4)
(setq-default indent-tabs-mode t)

;; make files up-to-date
(global-auto-revert-mode 1)

;; set this so you dont need to type yes and no
(defalias 'yes-or-no-p 'y-or-n-p)

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
(with-eval-after-load 'em-prompt
  (set-face-attribute 'eshell-prompt nil :foreground "#8BD5CA"))

;; org
(use-package
 org-modern
 :ensure t
 :hook (org-mode . org-modern-mode)
 :config
 (setq
  org-modern-star 'replace
  org-modern-table-vertical 1
  org-modern-table-horizontal 0.2
  org-modern-list '((43 . "➤") (45 . "–") (42 . "•"))
  org-modern-block-fringe nil
  org-modern-keyword nil
  org-modern-checkbox '((?X . "☑") (?- . "❍") (?\s . "☐"))
  org-modern-todo-faces
  '(("TODO" . (:foreground "orange" :weight bold))
    ("DONE" . (:foreground "green" :weight bold)))))

(use-package
 org
 :config
 (org-babel-do-load-languages
  'org-babel-load-languages '((python . t) (emacs-lisp . t)))
 (add-hook
  'org-babel-after-execute-hook 'org-redisplay-inline-images))

(setq org-confirm-babel-evaluate nil)
(setq org-startup-with-inline-images t)
(setq org-src-preserve-indentation t)
(setq
 python-shell-interpreter "python3"
 python-shell-interpreter-args ""
 python-shell-prompt-detect-enabled nil
 python-shell-completion-native-enable nil)
(setenv "PAGER" "cat")
(setq org-image-actual-width 400)

;; navigation
(use-package
 vertico
 :ensure t
 :init (vertico-mode)
 :bind
 (:map
  vertico-map
  ("C-j" . vertico-next)
  ("C-k" . vertico-previous)
  ("C-u" . vertico-scroll-down)
  ("C-d" . vertico-scroll-up)))
(use-package
 orderless
 :ensure t
 :config
 (setq
  completion-styles '(orderless basic)
  completion-category-defaults nil
  completion-category-overrides '((file (styles partial-completion)))))
(use-package
 consult
 :ensure t
 :bind
 (("C-x b" . consult-buffer)
  ("C-x C-r" . consult-recent-file)
  ("C-c g" . consult-grep)
  ("C-c f" . consult-find)
  ("C-c m" . consult-mark)
  ("C-c o" . consult-imenu)
  ("C-s" . consult-line)))

(use-package marginalia :ensure t :init (marginalia-mode))

;; melpa packages
(use-package
 drag-stuff
 :ensure t
 :bind
 (("C-S-<up>" . drag-stuff-up) ("C-S-<down>" . drag-stuff-down)))

;; treesitter is built in after v29
;; make sure those grammer repos versions support currently installed treesitter
(use-package
 treesit
 :ensure nil
 :config
 (setq
  treesit-language-source-alist
  '((python
     "https://github.com/tree-sitter/tree-sitter-python" "v0.20.4")
    (javascript
     "https://github.com/tree-sitter/tree-sitter-javascript"
     "v0.20.1")
    (typescript
     "https://github.com/tree-sitter/tree-sitter-typescript"
     "v0.20.3"
     "typescript/src")
    (tsx
     "https://github.com/tree-sitter/tree-sitter-typescript"
     "v0.20.3"
     "tsx/src")
    (rust "https://github.com/tree-sitter/tree-sitter-rust" "v0.20.4")
    (json "https://github.com/tree-sitter/tree-sitter-json" "v0.20.1")
    (yaml "https://github.com/ikatyang/tree-sitter-yaml" "v0.5.0")
    (bash "https://github.com/tree-sitter/tree-sitter-bash" "v0.20.4")
    (c "https://github.com/tree-sitter/tree-sitter-c" "v0.20.6")
    (cpp "https://github.com/tree-sitter/tree-sitter-cpp" "v0.20.3")
    (css "https://github.com/tree-sitter/tree-sitter-css" "v0.20.0")
    (go "https://github.com/tree-sitter/tree-sitter-go" "v0.20.0")
    (html
     "https://github.com/tree-sitter/tree-sitter-html" "v0.20.0"))))

;; auto install treesitter grammers
(dolist (lang
         '(python javascript typescript tsx rust json yaml bash go))
  (unless (treesit-language-available-p lang)
    (treesit-install-language-grammar lang)))

;; official packages
;; LSP
;; (use-package lsp-mode
;;   :ensure t
;;   :commands (lsp lsp-deferred))
;; (require 'lsp-mode)
;; (add-hook 'c-mode-hook #'lsp-deferred)
;; (add-hook 'c++-mode-hook #'lsp-deferred)
;; (add-hook 'python-mode-hook #'lsp-deferred)
(use-package
 eglot
 :ensure t
 :hook
 ((python-mode python-ts-mode c++-mode c-mode rust-mode)
  .
  eglot-ensure)
 :config
 (setq eglot-server-programs
       `(((python-ts-mode python-mode)
          .
          ,(eglot-alternatives
            '(("pyright-langserver" "--stdio") ("pyrefly" "lsp"))))))
 (add-to-list
  'eglot-server-programs '((c++-mode c-mode) . ("clangd"))))

;; eldoc buffer position
(add-to-list
 'display-buffer-alist
 '("\\*eldoc*" (display-buffer-at-bottom) (window-height . 10)))

;; ruff
;; just run ruff format

;; autocompletion
;; M-/ is the default emacs auto-completion, so use same key
(use-package
 company
 :ensure t
 :config
 (setq company-backends
       '((company-capf
          company-dabbrev-code
          company-yasnippet
          company-files
          company-keywords)))
 :bind (:map company-mode-map ("M-/" . company-complete)))
(global-company-mode 1)

;; go
(use-package
 go-mode
 :ensure t
 :hook ((go-mode . lsp) (before-save . gofmt-before-save)))

;; Enable Evil
(use-package
 evil
 :ensure t
 :init
 (setq evil-want-keybinding nil)
 (setq evil-want-C-u-scroll t)
 (setq evil-undo-system 'undo-redo) ; built-in undo-redo, only work after emacs 28
 :config
 (evil-mode 1)
 (define-key evil-normal-state-map (kbd "C-l") nil)
 (define-key evil-normal-state-map (kbd "C-h") nil)
 (define-key evil-motion-state-map (kbd "C-e") nil)
 (define-key evil-normal-state-map (kbd "C-r") 'undo-redo)
 ; im not sure why but H itself can spawn more emacs clients after reaching left most buffer
 (define-key evil-normal-state-map (kbd "C-S-l") 'evil-next-buffer)
 (define-key evil-normal-state-map (kbd "C-S-h") 'evil-prev-buffer)
 (define-key
  evil-normal-state-map
  (kbd "C-c d")
  'flymake-show-buffer-diagnostics)
 (define-key evil-normal-state-map (kbd "C-x !") 'shell-command) ; C-x p ! to run command under project root
 (define-key evil-normal-state-map (kbd "M-o") 'compile))

;; Somehow M-! Does Not work in evil mode
;; shift without deselect
(defun custom/evil-shift-right ()
  (interactive)
  (evil-shift-right evil-visual-beginning evil-visual-end)
  (evil-normal-state)
  (evil-visual-restore))
(defun custom/evil-shift-left ()
  (interactive)
  (evil-shift-left evil-visual-beginning evil-visual-end)
  (evil-normal-state)
  (evil-visual-restore))
(evil-define-key
 'visual global-map (kbd ">") 'custom/evil-shift-right)
(evil-define-key 'visual global-map (kbd "<") 'custom/evil-shift-left)

(use-package
 lsp-ui
 :ensure t
 :hook (lsp-mode . lsp-ui-mode)
 :config
 (setq
  lsp-ui-doc-enable t
  lsp-ui-doc-show-with-cursor nil
  lsp-ui-doc-position 'at-point)
 (define-key lsp-ui-mode-map (kbd "K") 'lsp-ui-doc-glance))

;; ligature 
(use-package
 ligature
 :ensure t
 :config
 (ligature-set-ligatures
  't
  '("<|"
    "|>"
    "<|>"
    "||"
    "|="
    "||-"
    "-|"
    "-||"
    "=="
    "!="
    "<="
    ">="
    "==="
    "!=="
    "=!="
    "<==>"
    "==>"
    "<===>"
    "===>"
    "<=>"
    "<=="
    "=="
    "->"
    "<-"
    "<-->"
    "-->"
    "<--->"
    "--->"
    "<->"
    "<--"
    "--"
    ".."
    "..."
    "..<"
    "::"
    ":::"
    ":="
    ":<"
    "!!"
    "?:"
    "??"
    "?."
    "?="
    "?!"
    "<>"
    "<<"
    ">>"
    "<<<"
    ">>>"
    "<->"
    "<=>"
    "<!--"
    "&&"
    "||"
    ":="
    "^="
    "++"
    "--"
    "+>"
    "<+"
    "+++"
    "--+"
    "+++"))
 (global-ligature-mode t))

(require 'evil)
(evil-mode 1)
(use-package
 evil-collection
 :ensure t
 :after evil
 :config (evil-collection-init))
(with-eval-after-load 'evil
  (add-hook
   'lsp-mode-hook
   (lambda ()
     (evil-local-set-key 'normal (kbd "K") 'lsp-ui-doc-glance))))

;; indent lines
(use-package
 indent-bars
 :ensure t
 :custom
 (indent-bars-color '("#4E4E4E"))
 (indent-bars-color-by-depth nil)
 (indent-bars-pattern ".")
 (indent-bars-highlight-current-depth nil)
 :hook
 ((python-mode emacs-lisp-mode js-mode typescript-mode)
  .
  indent-bars-mode))

;; embark can bring minibuffer content to regular buffer (e.g. grep, search commands)
;; export will apply addition mode based on the content of minibuffer
(use-package
 embark
 :ensure t
 :bind
 (("C-." . embark-act)
  :map
  minibuffer-local-map
  ("C-c C-c" . embark-collect)
  ("C-c C-e" . embark-export)))
(use-package embark-consult :ensure t)

;; multiple cursors
; usage
; for edit-lines, just use V to mark lines then do things
; for other stuffs, use in insert mode and c-spc otherwise cannot re-enter insert
; to exit, c-g or enter
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(define-key evil-insert-state-map (kbd "C->") 'mc/mark-next-like-this)
(define-key
 evil-insert-state-map (kbd "C-<") 'mc/mark-previous-like-this)
(define-key
 evil-insert-state-map (kbd "C-c m a") 'mc/mark-all-like-this)
; deactive mark after leaving multiple cursor
(add-hook
 'multiple-cursors-mode-disabled-hook (lambda () (deactivate-mark)))

;; email
; need to install mu4e and offlineimap system-wise
; for gmail with 2fa, an app password is needed
; outlook might be difficult to setup but you can use Gmailify to sync emails
(require 'mu4e)
(setq mail-user-agent 'mu4e-user-agent)
(setq mu4e-drafts-folder "/[Gmail].Drafts")
(setq mu4e-sent-folder "/[Gmail].Sent Mail")
(setq mu4e-trash-folder "/[Gmail].Trash")
(setq mu4e-sent-messages-behavior 'delete)
(setq mu4e-get-mail-command "true") ; set offlineimap as systemd service
(setq mu4e-update-interval 300)

(setq
 user-mail-address "zhiyuanyu06@gmail.com"
 user-full-name "Zhiyuan Yu"
 message-signature (concat "Zhiyuan Yu\n" "734-881-3648\n" "zhiyuanyu06@gmail.com\n"))

(require 'smtpmail)
(setq
 message-send-mail-function 'smtpmail-send-it
 smtpmail-smtp-server "smtp.gmail.com"
 smtpmail-smtp-service 587
 smtpmail-stream-type 'starttls)

;; ssh
;; in general, eshell works the best
(setq tramp-use-ssh-controlmaster-options nil) ; let tramp use local ssh master

;; mode line
(defface evil-normal-face
  '((t :background "#98C379" :foreground "black"))
  "evil mode face")
(defface evil-insert-face
  '((t :background "#C678DD" :foreground "black"))
  "evil mode face")
(defface evil-visual-face
  '((t :background "#E5C07B" :foreground "black"))
  "evil mode face")
(defun evil-mode-line-custom ()
  (cond
   ((eq evil-state 'normal)
    (propertize evil-mode-line-tag 'face 'evil-normal-face))
   ((eq evil-state 'insert)
    (propertize evil-mode-line-tag 'face 'evil-insert-face))
   ((eq evil-state 'visual)
    (propertize evil-mode-line-tag 'face 'evil-visual-face))
   (t
    evil-mode-line-tag)))
(setq-default mode-line-format
              '((:propertize
                 " Ɛ " face
                 (:background
                  "black"
                  :foreground "cyan"
                  :weight bold))
                (:eval (evil-mode-line-custom))
                " %m "
                (:propertize
                 (""
                  mode-line-mule-info
                  mode-line-client
                  mode-line-modified
                  mode-line-remote
                  mode-line-window-dedicated)
                 display (min-width (6.0)))
                "%e"
                mode-line-front-space
                mode-line-frame-identification
                mode-line-buffer-identification
                "   "
                mode-line-position
                (project-mode-line project-mode-line-format)
                (vc-mode vc-mode)
                "  "
                mode-line-modes
                mode-line-misc-info
                mode-line-end-spaces))

;; sometimes emacs automatcally add safe local variables etc here. Just remove them manually, wont cause any troubles.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("8168af544c8887e9ea1935b21868f126f7749ef70819a3109ffcedc84ce3ac91"
     "022461355526dfb4ba9ce63926976068bb4d64a6aabe6365d497e3b8a46eb837"
     "e15f9b5cb274a44a2b0ae8aaac104010025f65c52cc85997fb7124f81e8a5359"
     default))
 '(package-selected-packages
   '(company
     consult
     cython-mode
     drag-stuff
     elisp-autofmt
     embark
     embark-consult
     evil-collection
     git-gutter
     git-gutter-fringe
     go-mode
     indent-bars
     ligature
     lsp-ui
     lua-mode
     magit
     marginalia
     matlab-mode
     multiple-cursors
     ob-async
     orderless
     org-modern
     vertico
     yasnippet
     yasnippet-snippets)))

;; custom emacs tools
(load-file
 (expand-file-name "emacs-tools/init.el" user-emacs-directory))
