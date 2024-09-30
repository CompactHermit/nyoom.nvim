help:
	$(shell grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sed -n 's/^\(.*\): \(.*\)##\(.*\)/\1\3/p' | column -t  -s ')

js: #j
	jj squash

clean: #Clean
	echo "Cleaning Cargo.locks"
	rm -rf ./deps/plugins/_sources/neorg-se-*
	rm -rf ./deps/plugins/_sources/norg-fmt-*
	rm -rf ./deps/plugins/_sources/harper-ls-*
	rm -rf ./deps/plugins/_sources/tree-sitter-*
	rm -rf ./deps/parsers/_sources/treesitter-grammar-*
	echo "Adding git"
	git add .
