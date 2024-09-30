(local M {})
(local api vim.api)
(local get-extmarks api.nvim_buf_get_extmarks)
(local conf {:enabled true
             :mode :virtual
             :virt_text "󱓻 "
             :highlight {:hex true :lspvars true}})

(local ns (. (require :modules.tools.rgb.+colorify.state) :ns))
(fn M.is_dark [hex]
  (set-forcibly! hex (hex:gsub "#" ""))
  (local (r g b)
         (values (tonumber (hex:sub 1 2) 16) (tonumber (hex:sub 3 4) 16)
                 (tonumber (hex:sub 5 6) 16)))
  (local brightness (/ (+ (* r 299) (* g 587) (* b 114)) 1000))
  (< brightness 128))

(fn M.add_hl [hex]
  (let [name (.. :hex_ (hex:sub 2))]
    (var (fg bg) (values hex hex))
    (if (= conf.mode :bg) (set fg (or (and (M.is_dark hex) :white) :black))
        (set bg :none))
    (api.nvim_set_hl 0 name {: bg :default true : fg})
    name))

(fn M.not_colored [buf linenr col hl-group opts]
  (var ms (get-extmarks buf ns [linenr col] [linenr opts.end_col]
                        {:details true}))
  (when (= (length ms) 0) (lua "return true"))
  (set ms (. ms 1))
  (set opts.id (. ms 1))
  (not= hl-group (or (. ms 4 :hl_group) (. ms 4 :virt_text 1 2))))

M
