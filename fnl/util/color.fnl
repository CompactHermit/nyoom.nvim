(local M {})
(var (fok fox) (pcall require :nightfox.palette))
(when fok
  (set fox (fox.load :carbonfox))
  (tset M :carbonfox
        {:background fox.bg1
         :fancy_float {:border {:bg fox.bg1 :fg fox.bg0}
                       :title {:bg fox.cyan.dim :fg fox.bg0}
                       :window {:bg fox.bg0}}
         :harpoon_current fox.red.dim
         :hydra {:amaranth {:fg fox.red.bright}
                 :blue {:fg fox.blue.base}
                 :pink {:fg fox.pink.base}
                 :red {:fg fox.red.dim}
                 :teal {:fg fox.yellow.base}}
         :neorg {:heading1 {:fg fox.red.dim}
                 :heading2 {:fg fox.blue.base}
                 :heading3 {:fg fox.magenta.base}
                 :heading4 {:fg fox.cyan.dim}
                 :heading5 {:fg fox.green.bright}
                 :heading6 {:fg fox.cyan.bright}}
         :oil {:d "@constructor"
               :executable "@field"
               :l "@exception"
               :p "@constant.macro"
               :s "@attribute"}
         :starter {:current {:bg fox.bg4 :fg fox.white.base}
                   :header {:fg fox.green.dim}
                   :prefix {:fg fox.white.base}
                   :query {:fg fox.red.base}
                   :section {:fg fox.blue.base}}
         :status_line {:added fox.green.bright
                       :branch {:bg fox.bg2 :fg fox.cyan.base}
                       :changed fox.blue.base
                       :commandline fox.yellow.dim
                       :diff_bg fox.bg1
                       :filename {:bg fox.bg2}
                       :filetype {:bg fox.bg4}
                       :hydra {:mode {:bg fox.red.base :fg fox.bg2}
                               :name {:bg fox.bg2 :fg fox.red.dim}}
                       :inactive fox.bg4
                       :insert fox.white.dim
                       :molten {:bg fox.bg2 :fg fox.red.base}
                       :normal fox.cyan.base
                       :position {:bg fox.bg2 :link fox.cyan.base}
                       :removed fox.red.base
                       :replace fox.magenta.bright
                       :scroll {:bg fox.cyan.base :fg fox.bg2}
                       :search_count {:bg fox.bg3 :fg fox.pink.bright}
                       :terminal fox.pink.dim
                       :visual fox.magenta.bright}
         :telescope {:block {:fg fox.cyan.dim}
                     :charDev {:fg fox.cyan.dim}
                     :constant {:fg fox.cyan.dim}
                     :group {:fg fox.cyan.dim}
                     :main fox.bg0
                     :number {:fg fox.cyan.dim}
                     :pipe {:fg fox.cyan.dim}
                     :prompt fox.bg2
                     :promptPrefix {:fg fox.cyan.dim}
                     :read {:fg fox.cyan.dim}
                     :title {:bg fox.cyan.dim :fg fox.fg1}
                     :user {:fg fox.cyan.dim}}}))

M
