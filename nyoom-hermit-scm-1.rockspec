local _MODREV, _SPECREV = 'scm', '-1'
rockspec_format = '3.0'
packages = "nyoom.nvim"
_VERSION = _MODREV .. _SPECREV
test_dependencies = {
    'lua = 5.1',
    'plenary.nvim',
    'hotpot',
    'nlua',
    'nio'
}

source = {
    url = 'git://github.com/CompactHermit' ..package,
}

build = {
    type = 'builtin',
}
