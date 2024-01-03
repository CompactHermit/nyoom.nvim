project('faker', 'c', version: '0.1.0',
        default_options: ['c_std=c11', 'warning_level=2'])

cc = meson.get_compiler('c')

if(meson.get_compiler('c').get_id() == 'clang')
  add_project_arguments('-D_LIBC_DEBUG', language: 'c')
  add_global_arguments('-D_GNU_SOURCE', language: 'c')
endif

__required_deps = []
##DEPS HERE
__local_deps = [
]
foreach i : __local_deps
	__required_deps += [dependency(i, required: true)]
endforeach

__include_dirs = [
  include_directories('src')
]

__gcc_opts = [
  '--gcc-toolchain=$LIBCLANG_PATH'
]

if get_option('warning_level') != '0'
  warns = [ 'cast-function-type', 'ignored-qualifiers', 'missing-parameter-type',
            'nonnull', 'shadow', 'no-type-limits', 'old-style-declaration', 'override-init',
            'sign-compare', 'type-limits', 'uninitialized', 'shift-negative-value',
            'unused-but-set-parameter', 'unused-parameter', 'implicit-fallthrough=2',
            'no-unknown-warning-option', 'no-missing-braces', 'conversion', 'empty-body' ]
  foreach w : warns
          if cc.has_argument('-W'+w)
                  add_global_arguments('-W'+w, language: 'c')
          endif
  endforeach
endif


__sources = files(
  'src/main.c'
)


subdir('src')
