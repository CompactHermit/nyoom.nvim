(import-macros {: use-package!} :macros)

(local leet_session "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2NvdW50X3ZlcmlmaWVkX2VtYWlsIjpudWxsLCJhY2NvdW50X3VzZXIiOiI2NzdnOCIsIl9hdXRoX3VzZXJfaWQiOiIxMDQxMzk0NCIsIl9hdXRoX3VzZXJfYmFja2VuZCI6ImFsbGF1dGguYWNjb3VudC5hdXRoX2JhY2tlbmRzLkF1dGhlbnRpY2F0aW9uQmFja2VuZCIsIl9hdXRoX3VzZXJfaGFzaCI6ImU2MTkwMTM5MjEzNWU4YjJmMTgxNTcxNDg1MWU4YzdhMDkxZGU3ZWIiLCJpZCI6MTA0MTM5NDQsImVtYWlsIjoiY29tcGFjdGhlcm1pdGlhbkBwcm90b24ubWUiLCJ1c2VybmFtZSI6IkNvbXBhY3RIZXJtaXQiLCJ1c2VyX3NsdWciOiJDb21wYWN0SGVybWl0IiwiYXZhdGFyIjoiaHR0cHM6Ly9zMy11cy13ZXN0LTEuYW1hem9uYXdzLmNvbS9zMy1sYy11cGxvYWQvYXNzZXRzL2RlZmF1bHRfYXZhdGFyLmpwZyIsInJlZnJlc2hlZF9hdCI6MTY5MjA0MTkzNCwiaXAiOiIyNjAzOjMwMWI6NGQ2OmUwMDA6OmVlNmUiLCJpZGVudGl0eSI6IjQ1ZTQ3NDlmNzhhZWNhNjIwYzBlOWMxYzQ4YjliYTlhIiwic2Vzc2lvbl9pZCI6NDQzNDAwMzd9.ennhhrPFem08XKMy5SzvpB7nrH-YonPObzt-Bk2uee0")
(local cookie "RwNM1BomFUhI4SvRgIU4iuTZIEsvXXT9FlVNaig9pAji5SQk0NN32JHFqQkv8pHh")
;; Poetry plugin for neovim
(use-package! :AckslD/swenv.nvim
              {:nyoom-module lang.python
               :ft [:python]
               :cmd ["VenvFind" "GetVenv"]})

(use-package! :Dhanus3133/LeetBuddy.nvim
              {:opt true
               :dependecies [:nvim-lua/plenary.nvim
                              :nvim-telescope/telescope.nvim]
               :cmd ["LBQuestions"
                     "LBQuestion"
                     "LBReset"
                     "LBTest"
                     "LBSubmit"
                     "LeetActivate"]
               :config (fn []
                         (local {: setup} (require :leetbuddy))
                         (setup {:languages [:py :cpp :rs :go :rkt]}))})


; "Dhanus3133/LeetBuddy.nvim",
; lazy = true,
; dependencies = {
;                 "nvim-lua/plenary.nvim",
;                 "nvim-telescope/telescope.nvim",}
;     ,
;     cmd = {
;
;            "LBQuestions",
;            "LBQuestion",
;            "LBReset",
;            "LBTest",
;            "LBSubmit",
;            "LeetActivate",}
;     ,
;     config = function()
;         require("leetbuddy").setup({ language = "py"})
;         lambda.command("LeetActivate", function()
;                        local binds = {
;                                       ["<leader>lq"] = ":LBQuestions<cr>",
;                                       ["<leader>ll"] = ":LBQuestion<cr>",
;                                       ["<leader>lr"] = ":LBReset<cr>",
;                                       ["<leader>lt"] = ":LBTest<cr>",
;                                       ["<leader>ls"] = ":LBSubmit<cr>",}
;                        for x, v in pairs(binds) do
;                        vim.keymap.set("n", x, v, { noremap = true, silent = true})
;                        end
;                        end, {})
;     end,

;
