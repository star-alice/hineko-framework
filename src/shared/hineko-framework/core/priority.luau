local Priority = {}

function Priority:sortModuleByPriority(modules: { { priority: number } })
	local grouped: { [number]: { { priority: number } } } = {}
	local keys: { number } = {}

	for _, module in modules do
		local priority = module.priority or 0

		if not grouped[priority] then
			grouped[priority] = {}
			table.insert(keys, priority)
		end

		table.insert(grouped[priority], module)
	end

	table.sort(keys, function(a, b)
		return a > b
	end)

	local sorted: { { priority: number } } = {}

	for _, key in keys do
		for _, module in grouped[key] do
			table.insert(sorted, module)
		end
	end

	return sorted
end

return Priority
