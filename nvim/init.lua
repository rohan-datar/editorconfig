do
	local ok = pcall(require, vim.g.nix_info_plugin_name)
	if not ok then
		package.loaded[vim.g.nix_info_plugin_name or "nix-info"] = setmetatable({}, {
			__call = function(_, default)
				return default
			end,
		})
	end
end
_G.nixInfo = require(vim.g.nix_info_plugin_name or "nix-info")
-- load the plugins via paq/packer if nix is not present
require("fallback")

-- actual requires
require("config")
require("plugins")
