;; init.el --- main entry point tingz  -*- lexical-binding: t -*-

;; prelim
(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 5)
(menu-bar-mode -1)
(setq visible-bell nil)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; font + theme
(set-face-attribute 'default nil :font "Iosevka Nerd Font" :height 200)
(load-theme 'modus-vivendi t)

;; initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; initialize use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; LINE NUMBERS!!
(column-number-mode)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

;; disable line numbers for some modes
(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; completion packages
(use-package vertico
  :config
  (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles . (partial-completion))))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(all-the-icons company doom-modeline evil evil-collection evil-magit
		   general hydra magit orderless projectile
		   rainbow-delimiters vertico vterm)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; code completion
(use-package company
  :config
  (global-company-mode 1)
  :custom
  (company-lighter nil))

;; diagnostics
(setq flymake-mode-line-format nil)

;; documentation
(setq eldoc-minor-mode-string nil)

;; editing
(setq-default abbrev-mode nil)

;; modeline
(use-package all-the-icons)

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-icon nil))

;; rainbow delims
(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))

;; which key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; general keybinds
(use-package general
  :config
  (general-create-definer sjm/leader-keys
     :keymaps '(normal insert visual emacs)
     :prefix "SPC"
     :global-prefix "C-SPC"))


;; EVIL
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; hydra | text scaling
(use-package hydra)

(defhydra hydra-text-scale (:timeout 4)
	  "scale text"
	  ("j" text-scale-increase "in")
	  ("k" text-scale-decrease "out")
	  ("f" nil "finished" :exit t))

;; vterm opening behavior
(defun my/vterm-below ()
  (interactive)
  (split-window-below -15)
  (other-window 1)
  (vterm))

;; frame-splitting behavior
(defun my/split-window-below-and-focus ()
  (interactive)
  (split-window-below)
  (other-window 1))

(defun my/split-window-right-and-focus ()
  (interactive)
  (split-window-right)
  (other-window 1))

;; KEYBINDS

(sjm/leader-keys
  ;; prefixes
  "t"  '(:ignore t :which-key "toggles")
  "e"  '(:ignore t :which-key "evaluate")

  ;; general
  "v"  '(my/vterm-below :which-key "vterm")
  "d"  '(dired :which-key "dired")
  "q"  '(delete-window :which-key "close window")
  "s"  #'save-buffer

  ;; text scaling
  "ts" '(hydra-text-scale/body :which-key "scale text")

  ;; window mgmt
  "ws" '(my/split-window-below-and-focus :which-key "split below")
  "wv" '(my/split-window-right-and-focus :which-key "split right")
  "wh" '(windmove-left :which-key "window left")
  "wj" '(windmove-down :which-key "window down")
  "wk" '(windmove-up :which-key "window up")
  "wl" '(windmove-right :which-key "window right")

  ;; eval
  "el" #'eval-last-sexp
  "er" #'eval-region
  "eb" #'eval-buffer)
