;; extends
;; inherits: norg

; Extended folds on Ranged_Verbatim tags
(ranged_verbatim_tag
    name: (tag_name) @_name
    (#eq? @_name "document.meta")
) @fold
[
    (heading1)
    (heading2)
    (heading3)
    (heading4)
    (heading5)
    (heading6)
] @fold
(ranged_verbatim_tag
          name: (tag_name) @name (#eq? @name "data")) @fold
