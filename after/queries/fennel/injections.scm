;; extends

;; NOTE: Hermit Would love to add any arbitrary injections, but later
; (fn_form
;   (comment
;     body:
;         (comment_body) @injection.language)
;   (docstring) @injection.content
;   (#set! @injection.language "))

(fn_form
  (docstring) @injection.content
  (#set! injection.language "norg"))
