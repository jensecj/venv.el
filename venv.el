;;; venv.el. --- Automatic virtual environments -*- lexical-binding: t; -*-

;; Copyright (C) 2021

;; Author:  <jens@subst.net>
;; URL: https://www.github.com/jensecj/venv.el
;; Keywords: python, virtualenv
;; Package-Requires ((emacs "28.0.50")(dash "2.18.1")(f "0.20.0"))
;; Package-Version: 20210313
;; Version: 0.1.0


;;; Commentary:
;;

;;; Code:

(defvar-local venv-current nil "current virtual environment")

(defvar venv-pyenv-path (expand-file-name "~/.pyenv/versions/")
  "Path to pyenv virtual environments")

(defvar venv-pyenv-file ".python_version" "Pyenv file")

(defun venv--activate (venv)
  (when venv
    (let* ((venv-path (cdr venv))
           (venv-name (f-base venv-path)))
      (setq-local venv-current venv-name)

      (setq-local python-shell-virtualenv-root venv-path)

      (comment
       (make-local-variable 'process-environment)
       (setenv ...))
      ))
  )

(defun venv--get-pyenv-from-project ()
  (when-let* ((proj (project-current))
              (root (project-root proj))
              (pyenv (f-join root venv-pyenv-file))
              (_ (f-exists-p pyenv))
              (name (s-trim (f-read pyenv)))
              (venv-path (f-join venv-pyenv-path name))
              (_ (f-exists-p venv-path)))
    (cons 'pyenv venv-path)))

(defun venv--get-pyenv-from-file ()
  (when-let* ((pyenv-path
               (locate-dominating-file default-directory
                                       (lambda (path)
                                         (f-exists-p (f-join path venv-pyenv-file)))))
              (venv-name (s-trim (f-read (f-join pyenv-path venv-pyenv-file))))
              (venv-path (f-join venv-pyenv-path venv-name)))
    (when (f-exists-p venv-path)
      (cons 'pyenv venv-path))))

(defun venv--get-venv-from-project ()
  (when-let* ((proj (project-current))
              (root (project-root proj))
              (venv-path (f-join root "venv"))
              (_ (f-exists-p venv-path)))
    (cons 'venv venv-path)))

(defun venv--get-venv-from-file ()
  (when-let ((venv-path
              (locate-dominating-file default-directory
                                      (lambda (path)
                                        (f-exists-p (f-join path "venv"))))))
    (cons 'venv venv-path)))

(defun venv--get ()
  (or (venv--get-pyenv-from-project)
      (venv--get-pyenv-from-file)
      (venv--get-venv-from-project)
      (venv--get-venv-from-file)))

(defun venv-update ()
  (interactive)
  (venv--activate (venv--get)))

(defun venv-list ()
  '())

;;;###autoload
(defun venv-activate ()
  (interactive)
  (when-let* ((venvs (venv-list))
              (pick (completing-read "venv: " venvs)))
    (venv--activate pick)))

(define-minor-mode venv-auto-mode
  ""
  nil "" nil
  (if venv-auto-mode
      (progn
        (venv--activate (venv--get)))
    (dolist (v '(venv-current
                 python-shell-virtualenv-path
                 python-shell-virtualenv-root))
      (kill-local-variable v))))


(provide 'venv)
;;; venv.el ends here
