;; TODO: (Hermit) This is all a load of bullshit,
;; Pretty sure have of this is ai-generated.
;; We can just set a metatable
(local states {})
(local trigger-load (. (require :lz.n) :trigger_load))
(fn call [mod-path]
  (let [plugins {}]
    (each [_ has (pairs states)] (local plugin (has mod-path))
      (when (not= plugin nil) (table.insert plugins plugin)))
    (when (not= plugins {}) (trigger-load plugins) (values true))
    false))

(fn starts-with [str prefix]
  (when (or (= str nil) (= prefix nil)) (lua "return false"))
  (= (string.sub str 1 (string.len prefix)) prefix))

(local M {:del (fn [plugin] (tset states plugin.name nil))
          :spec_field :on_require})

(fn M.add [plugin]
  (let [on-req plugin.on_require]
    (var mod-paths {})
    (if (= (type on-req) :table) (set mod-paths on-req)
        (= (type on-req) :string) (set mod-paths [on-req])
        (lua "return "))
    (tset states plugin.name (fn [mod-path]
                               (each [_ v (ipairs mod-paths)]
                                 (when (starts-with mod-path v)
                                   (lua "return plugin")))
                               nil))))

(local oldrequire require)
(tset (require :_G) :require (fn [mod-path]
                               (let [(ok value) (pcall oldrequire mod-path)]
                                 (when ok (lua "return value"))
                                 (tset package.loaded mod-path nil)
                                 (when (= (call mod-path) true)
                                   (let [___antifnl_rtns_1___ [(oldrequire mod-path)]]
                                     (lua "return (table.unpack or _G.unpack)(___antifnl_rtns_1___)")))
                                 (error value))))

M
