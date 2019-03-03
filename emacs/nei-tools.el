
(defvar nei--detect-ipynb-regexp "{\n \"cells\": \\[\n  {\n" ;; e.g for string-match: 
  "Regular expression used to detect IPYNB JSON")

(defun nei--visited-file-type ()
  "Returns PY or IPYNB or nil if no file is being visited"
  (cond ((s-ends-with? ".ipynb" (buffer-file-name)) "IPYNB")
        ((s-ends-with? ".py"(buffer-file-name)) "PY")))



(defun nei--insert-ipynb-point (&optional insert-anywhere)
  ;; Can make safer - e.g check for EOL
  "Added a special text marker for the point in IPYNB buffer to track the point.
   Returns t if the marker is added, nil otherwise.

  If anywhere, will insert the marker at the point position which may break the JSON.
  "
  (if insert-anywhere (insert "NEI-POINT>")
    (ignore-errors
      (let ((nei-point-marker "NEI-POINT>")
            (line-boundary (and (looking-back "^    " 4)
                                (s-equals? (string (char-after)) "\""))))
        (if line-boundary
            (progn
              (forward-char)
              (insert nei-point-marker)))
        t
        )
      )
    )
  )


(defun nei--locate-ipynb-point (text)
  "Without mutating the current buffer, return a cons of the appropriate
   point and text cleaned of the temporary marker"
  (with-temp-buffer
    (insert text)
    (beginning-of-buffer)
    (while (re-search-forward "NEI-POINT>" nil t)
      (replace-match "" nil nil))
    (cons (point) (buffer-string))
    )
  )


(defun nei--marked-source (&optional anywhere)
  (let ((buffer-contents (buffer-string))
        (point-pos (point)))
    (with-temp-buffer
      (insert buffer-contents)
      (goto-char point-pos)
      (nei--insert-ipynb-point anywhere)
      (buffer-string)
      )
    )
  )

(defun nei-parse-ipynb-buffer (backoff)
  "Parse the JSON contents of an ipynb buffer returning the results as Python code"
  (condition-case nil
      (nei--cells-to-text
       (nei-parse-json (json-read-from-string (nei--marked-source backoff))))
    (error (nei--cells-to-text
            (nei-parse-json (json-read-from-string (buffer-string)))))
    )
  )

(defun nei-add-file-mode-line ()
  "Add a file mode line"
  (interactive)
  (beginning-of-buffer)
  (insert "# -*- mode: python; eval: (nei-mode)-*-\n\n")
  )


(defun nei-view-ipynb ()
  "Open a NEI view on an IPYNB file"
  (interactive)
  (nei--ipynb-buffer t)
  )

(defun nei--ipynb-buffer (&optional backoff background keep-original)
  "backoff - attempt reparse. 
   background - switch to buffer.
   keep-original - kill original buffer or not"
  (let* ((text (nei-parse-ipynb-buffer backoff))
         (nei-buffer-name (s-prepend "NEI>" (buffer-name)))
         (new-bufferp (not (get-buffer nei-buffer-name)))
         (nei-buffer (get-buffer-create nei-buffer-name))
         )

      
      (with-current-buffer nei-buffer
        (let* ((point-and-clean-text (nei--locate-ipynb-point text))
               (new-point-pos (car point-and-clean-text))
               (clean-text (cdr point-and-clean-text)))
             
          (if new-bufferp
              (progn (insert clean-text) (nei-mode)))
      
          (if (not background)
              (progn 
                (switch-to-buffer nei-buffer)
                (goto-char new-point-pos)
                (recenter)
                )
            )
          )
        )
    
      (if (not keep-original)
          (kill-buffer (current-buffer)))
      )
  (set-buffer-modified-p nil)
  )



(defun nei-next-error-hook ()
  (if (s-equals? (nei--visited-file-type) "IPYNB") 
      (nei--ipynb-buffer)
    )
  )

(defun nei--ipynb-suggestion ()
  (message "Switch to NEI mode using the nei-view-ipynb command")
  (fundamental-mode)
  )

(defun nei-rgrep-integration () ;; Make into toggle
  "Uses magic-fallback-mode-alist to handle .ipynb files opened in dired mode"
  (interactive)
  (add-hook 'next-error-hook #'nei-next-error-hook)
  (setq magic-fallback-mode-alist
            (append
             '(("{\n \"cells\": \\[\n  {\n" . nei--ipynb-suggestion))
             magic-fallback-mode-alist))
  )

(provide 'nei-tools)
