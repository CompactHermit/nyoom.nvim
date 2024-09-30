;(local {: register} (autoload :which-key))
(import-macros {: map!} :macros)
(local {: add : setup : show} (autoload :which-key))

(setup {:icons {:breadcrumb "»"
                :separator "->"
                :group "+"
                :rules [{:pattern :paste :icon "" :hl "@string"}
                        {:pattern :yank :icon "" :hl "@label"}
                        {:pattern :insert :icon "" :hl "@string"}
                        {:pattern :save :icon "󰆓" :hl "@number"}
                        {:pattern :buffer :icon "" :hl :structure}
                        {:pattern :tab :icon "" :color :red}
                        {:pattern :lazy :icon "󰏗" :hl "@number"}
                        {:pattern :grep :icon "" :color :red}
                        {:pattern :browser :icon "" :color :red}
                        {:pattern :help :icon "" :color :red}
                        {:pattern :buffers :icon "" :color :red}
                        {:pattern :view :icon "" :color :red}
                        {:pattern :error :icon "" :hl "@number"}
                        ;{:pattern :Conjufre :icon "" :hl "@label"}
                        {:pattern :direnv :icon "󱄅" :color :blue}
                        {:pattern :oil :icon "" :color :blue}
                        {:pattern :tmux :icon "" :color :green}
                        {:pattern :quickfix :icon "" :hl :structure}]}
        :preset :modern
        :show_help false
        :notify false
        :plugins {:presets {:operators true :motion true :windows true}}
        :layout {:spacing 1}
        :height {:min 0 :max 6}
        :align :center})

(add [{:mode :n}
      {1 {1 :<leader><tab> :group :+workspace}}
      {2 {1 :<leader>c :group :+code}}
      {3 {1 :<leader>cl :group "+Code::Lsp"}}
      {4 {1 :<leader>ct :group "Toggle LspLines"}}
      {5 {1 :<leader>b :group :+buffer}}
      {6 {1 :<M-s> :group :+flash}}
      {7 {1 :<leader>i :group :+insert}}
      {8 {1 :<leader>n :group "[Ne]org"}}
      {9 {1 :<leader>nc :group :+roam}}
      {10 {1 :m :group "[Co]njure [E]val"}}
      {11 {1 :<leader>nt :group "+[Ne]org [T]asks"}}
      {12 {1 ";t" :group "[Hy]dra [Tel]escope"}}
      {13 {1 :z :group "[F]old"}}
      {14 {1 :<leader>nm :group "+[Ne]org [M]ode"}}
      {15 {1 :<leader>nq :group :+quicknote}}
      {16 {1 :<leader>nu :group "+[Ne]org [E]xec"}}
      {17 {1 :<leader>q :group :+quit/session}}
      {18 {1 :<leader>r :group :+remote}}
      {19 {1 :<leader>s :group :+Swap}}
      {20 {1 :<leader>S :group :+Flash}}
      {21 {1 :<leader>l :group :+toggle}}
      {22 {1 :<leader>t :group :+toggle}}
      {23 {1 :<leader>w :group :+window}}
      {24 {1 :<leader>m :group :+Conjure}}
      {25 {1 :<leader>d :group :+debug}}
      {26 {1 :<leader>u :group :+test}}
      {27 {1 :<leader>v :group :+visual}}
      {28 {1 :<leader>z :group :+Tmux}}])

; (map! [n] :g #((. (require :which-key) :show) {:keys :g :loop true})
;       {:desc "[W]hich [K]ey <g>"})

(map! [n] :<space>
      #((. (require :which-key) :show) {:keys :<space> :loop true})
      {:desc "[W]hich [K]ey <leader>"})
