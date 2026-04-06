return {
	ERROR = {
		ALREADY_IGNITED = "Loader has already been ignited.",
		NOT_IGNITED = "Loader must be ignited before accessing its properties or methods.",
		INVALID_PATH = "Invalid path provided. Paths must be Roblox Folder instances.",
		MODULE_NOT_FOUND = function(moduleName: string)
			return `Module '{moduleName}' not found. Make sure it is loaded before trying to access it.`
		end,
		INVALID_MODULE = "Invalid module provided. Make sure it is a Roblox ModuleScript instance and that it is properly loaded.",
	},
}
