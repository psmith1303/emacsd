;;; init.el --- Where all the magic begins

(if (version< emacs-version "25.1") ; Minimum version 
    (error "Your Emacs is too old -- this config requires v25.1 or higher"))

;; This file loads Org-mode and then loads the rest of our Emacs
;; initialization from Emacs lisp embedded in psmith.org

(setq gc-cons-threshold 20000000)

;; add MELPA, Org, and ELPY
(require 'package)

(setq package-archives
      '(("elpy"  . "https://jorgenschaefer.github.io/packages/")
        ("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")
        ("org"   . "http://orgmode.org/elpa/")))

(package-initialize)

;; Bootstrap 'use-package' and 'org-mode
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(unless (package-installed-p 'org-plus-contrib)
  (package-refresh-contents)
  (package-install 'org-plus-contrib))

(eval-when-compile
(require 'use-package))
(require 'diminish)
(require 'bind-key)

;; load up all literate org-mode files in this directory
;(require 'org)
;
;
;(org-babel-load-file (concat user-emacs-directory "psmith.org"))

(let* ((org (expand-file-name "psmith.org" user-emacs-directory))
       (el  (expand-file-name "psmith.el" user-emacs-directory))
       (elc (concat el "c")))
  (when (and (file-exists-p elc)
             (file-newer-than-file-p org elc))
    (message "Byte compiled init is old - deleting...")
    (dolist (file (directory-files user-emacs-directory nil "\\.elc$"))
      (delete-file (expand-file-name file user-emacs-directory))))

  (cond ((file-exists-p elc) (load elc nil t))
        (t
         (when (file-newer-than-file-p org el)
           (message "Tangling the literate config...")
           (unless (call-process "emacs" nil nil nil "--batch" "-l" "ob-tangle" "--eval"
                                 (format "(org-babel-tangle-file \"%s\" \"%s\" \"emacs-lisp\")" org el))
             (warn "There was a problem tangling the literate config")))

         (load el nil t))))

(setq gc-cons-threshold 800000)


;;; init.el ends here

