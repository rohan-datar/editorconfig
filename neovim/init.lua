-- fallback for non-nix
require("nixCatsUtils").setup({
	non_nix_value = true,
})

-- load the plugins via paq/packer if nix is not present
require("fallback")

-- actual requires
require("config")
require("plugins")

if nixCats("lsp") then
	require("lsp")
end
