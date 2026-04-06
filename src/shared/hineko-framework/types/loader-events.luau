export type IgnitedResult = () -> ()
export type ModuleLoadedResult = { name: string, module: ModuleScript }
export type ModuleErrorResult = { name: string, error: string }

export type Names = "ignited" | "moduleLoaded" | "moduleError" | "finished"

return {}
