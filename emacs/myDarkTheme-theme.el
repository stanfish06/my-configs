;;; myDarkTheme-theme.el --- Monochrome dark theme inspired by stanfish06/monochrome.nvim -*- lexical-binding: t; -*-

;; Copyright (C) 2025

;; Author: stanfish06
;; Version: 2.0
;; Package-Requires: ((emacs "24.1"))
;; URL: https://github.com/stanfish06/my-configs
;; Keywords: faces, theme, monochrome, dark

;;; Commentary:

;; This theme is a port of the monochrome.nvim Neovim theme to Emacs.
;; It features a minimalist dark design with a focus on grayscale tones
;; and subtle accent colors for better readability and reduced eye strain.
;;
;; Color scheme philosophy:
;; - Background: #1E1E1E (dark gray)
;; - Foreground: #EBEBEB (light gray)
;; - Grayscale palette: 9 shades from dark to light (gray1-gray9)
;; - Minimal accent colors for syntax highlighting:
;;   - Keywords: Yellow (#FCE566)
;;   - Functions: Blue-gray (#b8c0e0)
;;   - Strings: Green (#a6da95)
;;   - Types: Blue (#6694a9)
;;   - Comments: Gray3 (italic)
;;
;; Usage:
;;   (load-theme 'myDarkTheme t)

;;; Code:

(deftheme myDarkTheme
  "A monochrome theme inspired by stanfish06/monochrome.nvim.
Dark theme with minimal use of colors, focusing on grayscale with subtle accents.")

;; Color palette based on monochrome.nvim default style
(let ((fg "#EBEBEB")
      (bg "#1E1E1E")
      (bg-alt "#252525")
      (fg-alt "#DEDEDE")
      ;; Grayscale palette (gray1-gray9)
      (gray1 "#2E2E2E")
      (gray2 "#3E3E3E")
      (gray3 "#4E4E4E")
      (gray4 "#5E5E5E")
      (gray5 "#6E6E6E")
      (gray6 "#7E7E7E")
      (gray7 "#8E8E8E")
      (gray8 "#9E9E9E")
      (gray9 "#DEDEDE")
      ;; Accent colors from monochrome.nvim
      (yellow "#FCE566")
      (yellow-gray "#B1AC8C")
      (green "#a6da95")
      (green-gray "#A4B5A7")
      (blue "#6694a9")
      (blue-gray "#b8c0e0")
      (cool-gray "#F9FAFB")
      ;; Bright colors
      (bright-red "#ffc4c4")
      (bright-green "#eff6ab")
      (bright-yellow "#ffe6b5")
      (bright-blue "#c9e6fd")
      (bright-purple "#f7d7ff")
      (bright-aqua "#ddfcf8")
      (bright-orange "#ffd3c2")
      ;; Faded colors
      (faded-red "#ec8989")
      (faded-green "#c9d36a")
      (faded-yellow "#ceb581")
      (faded-blue "#8abae1")
      (faded-purple "#db9fe9")
      (faded-aqua "#abebe2")
      (faded-orange "#E69E83")
      ;; Neutral colors
      (neutral-red "#eca8a8")
      (neutral-green "#ccd389")
      (neutral-yellow "#efd5a0")
      (neutral-blue "#a5c6e1")
      (neutral-purple "#e1bee9")
      (neutral-aqua "#c7ebe6")
      (neutral-orange "#efb6a0"))

  (custom-theme-set-faces
   'myDarkTheme
   
   ;; Base faces
   `(default ((t (:family "VictorMono Nerd Font Mono" :foundry "PfEd" :width normal :height 113 :weight medium :slant normal :foreground ,fg :background ,bg))))
   `(cursor ((t (:background ,fg))))
   `(fixed-pitch ((t (:family "Monospace"))))
   `(variable-pitch ((t (:family "Sans Serif"))))
   
   ;; Basic UI
   `(fringe ((t (:background ,bg))))
   `(highlight ((t (:background ,gray2))))
   `(region ((t (:background ,gray2 :foreground ,fg))))
   `(secondary-selection ((t (:background ,gray3))))
   `(trailing-whitespace ((t (:background ,faded-red))))
   `(shadow ((t (:foreground ,gray5))))
   `(escape-glyph ((t (:foreground ,faded-blue))))
   `(homoglyph ((t (:foreground ,faded-blue))))
   
   ;; Line numbers and cursor line
   `(line-number ((t (:foreground ,gray3 :background ,bg))))
   `(line-number-current-line ((t (:foreground ,gray8 :background ,bg-alt :weight bold))))
   `(hl-line ((t (:background ,bg-alt))))
   
   ;; Mode line
   `(mode-line ((t (:foreground ,fg :background ,gray2 :box nil))))
   `(mode-line-inactive ((t (:foreground ,gray5 :background ,gray1 :box nil))))
   `(mode-line-buffer-id ((t (:weight bold))))
   `(mode-line-emphasis ((t (:weight bold))))
   `(mode-line-highlight ((t (:background ,gray3))))
   
   ;; Font lock (syntax highlighting) - following monochrome.nvim mapping
   `(font-lock-comment-face ((t (:foreground ,gray3 :slant italic))))
   `(font-lock-comment-delimiter-face ((t (:inherit font-lock-comment-face))))
   `(font-lock-doc-face ((t (:foreground ,gray4 :slant italic))))
   `(font-lock-string-face ((t (:foreground ,green))))
   `(font-lock-keyword-face ((t (:foreground ,yellow))))
   `(font-lock-builtin-face ((t (:foreground ,gray4))))
   `(font-lock-function-name-face ((t (:foreground ,blue-gray))))
   `(font-lock-variable-name-face ((t (:foreground ,cool-gray))))
   `(font-lock-type-face ((t (:foreground ,blue))))
   `(font-lock-constant-face ((t (:foreground ,yellow-gray))))
   `(font-lock-warning-face ((t (:foreground ,faded-orange :weight bold))))
   `(font-lock-negation-char-face ((t (:foreground ,fg))))
   `(font-lock-preprocessor-face ((t (:foreground ,gray7))))
   `(font-lock-regexp-grouping-backslash ((t (:weight bold))))
   `(font-lock-regexp-grouping-construct ((t (:weight bold))))
   `(font-lock-number-face ((t (:foreground ,fg :weight bold))))
   
   ;; Additional font-lock faces
   `(font-lock-bracket-face ((t (:foreground ,fg))))
   `(font-lock-delimiter-face ((t (:foreground ,fg))))
   `(font-lock-escape-face ((t (:foreground ,green))))
   `(font-lock-misc-punctuation-face ((t (:foreground ,fg))))
   `(font-lock-operator-face ((t (:foreground ,fg))))
   `(font-lock-property-name-face ((t (:foreground ,gray5))))
   `(font-lock-property-use-face ((t (:foreground ,gray5))))
   `(font-lock-punctuation-face ((t (:foreground ,fg))))
   `(font-lock-variable-use-face ((t (:foreground ,cool-gray))))
   `(font-lock-function-call-face ((t (:foreground ,blue-gray))))
   `(font-lock-doc-markup-face ((t (:foreground ,yellow-gray))))
   
   ;; Search
   `(isearch ((t (:foreground ,bg :background ,bright-blue :weight bold))))
   `(isearch-fail ((t (:background ,faded-red))))
   `(lazy-highlight ((t (:foreground ,bg :background ,faded-blue))))
   `(match ((t (:background ,gray4))))
   `(query-replace ((t (:inherit isearch))))
   
   ;; Links
   `(link ((t (:foreground ,bright-blue :underline t))))
   `(link-visited ((t (:foreground ,faded-purple :underline t))))
   `(button ((t (:inherit link))))
   
   ;; Minibuffer and prompts
   `(minibuffer-prompt ((t (:foreground ,gray7 :weight bold))))
   
   ;; Completions (popup menu)
   `(completions-common-part ((t (:foreground ,fg))))
   `(completions-first-difference ((t (:foreground ,yellow :weight bold))))
   
   ;; Header line
   `(header-line ((t (:foreground ,fg :background ,gray2 :box nil))))
   
   ;; Tooltip
   `(tooltip ((t (:foreground ,bg :background ,gray8))))
   
   ;; Error/Warning/Success
   `(error ((t (:foreground ,faded-red :weight bold))))
   `(warning ((t (:foreground ,faded-yellow :weight bold))))
   `(success ((t (:foreground ,faded-green :weight bold))))
   
   ;; Diffs
   `(diff-added ((t (:foreground ,neutral-green :background ,bg))))
   `(diff-removed ((t (:foreground ,neutral-red :background ,bg))))
   `(diff-changed ((t (:foreground ,neutral-blue :background ,bg))))
   `(diff-header ((t (:foreground ,gray7 :background ,bg))))
   `(diff-file-header ((t (:foreground ,fg :weight bold))))
   `(diff-refine-added ((t (:foreground ,bright-green :background ,gray2))))
   `(diff-refine-removed ((t (:foreground ,bright-red :background ,gray2))))
   `(diff-refine-changed ((t (:foreground ,bright-blue :background ,gray2))))
   
   ;; Compilation
   `(compilation-info ((t (:foreground ,neutral-green))))
   `(compilation-warning ((t (:foreground ,neutral-yellow))))
   `(compilation-error ((t (:foreground ,neutral-red))))
   
   ;; Org mode (if used)
   `(org-level-1 ((t (:foreground ,fg :weight bold))))
   `(org-level-2 ((t (:foreground ,gray8 :weight bold))))
   `(org-level-3 ((t (:foreground ,gray7 :weight bold))))
   `(org-level-4 ((t (:foreground ,gray6))))
   `(org-level-5 ((t (:foreground ,gray5))))
   `(org-level-6 ((t (:foreground ,gray5))))
   `(org-level-7 ((t (:foreground ,gray4))))
   `(org-level-8 ((t (:foreground ,gray4))))
   `(org-link ((t (:foreground ,bright-blue :underline t))))
   `(org-todo ((t (:foreground ,faded-yellow :weight bold))))
   `(org-done ((t (:foreground ,faded-green :weight bold))))
   `(org-code ((t (:foreground ,gray6))))
   `(org-verbatim ((t (:foreground ,gray6))))
   `(org-block ((t (:background ,gray1 :foreground ,fg :extend t))))
   `(org-block-begin-line ((t (:foreground ,gray4 :background ,gray1 :extend t))))
   `(org-block-end-line ((t (:foreground ,gray4 :background ,gray1 :extend t))))
   
   ;; Markdown (if used)
   `(markdown-header-face-1 ((t (:foreground ,fg :weight bold))))
   `(markdown-header-face-2 ((t (:foreground ,gray8 :weight bold))))
   `(markdown-header-face-3 ((t (:foreground ,gray7 :weight bold))))
   `(markdown-link-face ((t (:foreground ,bright-blue))))
   `(markdown-url-face ((t (:foreground ,bright-blue :underline t))))
   `(markdown-code-face ((t (:foreground ,gray6 :background ,gray1))))
   `(markdown-inline-code-face ((t (:foreground ,gray6))))
   
   ;; Show paren
   `(show-paren-match ((t (:weight bold :underline t))))
   `(show-paren-mismatch ((t (:foreground ,faded-red :weight bold))))
   
   ;; Whitespace mode
   `(whitespace-space ((t (:foreground ,gray2))))
   `(whitespace-tab ((t (:foreground ,gray2))))
   `(whitespace-newline ((t (:foreground ,gray2))))
   `(whitespace-trailing ((t (:background ,faded-red))))
   `(whitespace-line ((t (:background ,gray1))))
   
   ;; Additional faces for compatibility
   `(next-error ((t (:inherit region))))
   `(vertical-border ((t (:foreground ,gray2))))))

(provide-theme 'myDarkTheme)

;; Local Variables:
;; no-byte-compile: t
;; End:

;;; myDarkTheme-theme.el ends here
