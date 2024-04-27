;;https://github.com/neovim/neovim/blob/381806729db1016106b02d866c4f4f64f76a351f/src/nvim/highlight_group.c
(local links {"@lsp.mod.strong.typst" "@markup.strong"
              "@lsp.mod.emph.typst" "@markup.italic"
              "@lsp.type.bool.typst" "@boolean"
              "@lsp.type.escape.typst" "@string.escape"
              "@lsp.type.link.typst" "@markup.link"
              "@lsp.typemod.delim.math.typst" "@punctuation"
              "@lsp.typemod.operator.math.typst" "@operator"
              "@lsp.type.heading.typst" "@markup.heading"
              "@lsp.type.pol.typst" "@variable"
              "@lsp.type.error.typst" :DiagnosticError
              "@lsp.type.term.typst" "@markup.bold"
              "@lsp.type.marker.typst" "@punctuation"
              "@lsp.type.ref.typst" "@label"
              "@lsp.type.label.typst" "@label}"})

(each [ng og (ipairs links)]
  (vim.api.nvim_set_hl 0 ng {:link og :default true}))
