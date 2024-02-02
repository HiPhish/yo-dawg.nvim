-- SPDX-License-Identifier: MIT

local M = {}

local INV_ARGS_TEMPLATE = 'Invalid arguments: %s'
local INV_CMD_TEMPLATE = 'Command not executable: %s'
local COMMAND = {'nvim', '--embed', '--headless'}
local DEFAULT_JOBOPTS = {
	rpc = true,
	width = 80,
	height = 40,
}

---Weak table which maps Neovim instance wrappers to the corresponding job ID.
---The table has weak keys, which means entries will be removed once the
---corresponding key object has been garbage-collected.  We need this table
---because we do not want to expose the job ID to the user.
local channels = setmetatable({}, {
	__mode = 'k',
})

---Maps method names to method functions to avoid repeatedly creating the same
---function over and over again.
local methods = {
}


---Metatable of all Neovim instances
local mt = {
	__index = function(nvim, key)
		local is_async = key:find('^async_') ~= nil
		local method = string.format('nvim_%s', key:gsub('^async_', '', 1))
		local result = methods[key] or function(self, ...)
			local jobid = channels[self]
			if is_async then
				vim.rpcnotify(jobid, method, ...)
				return
			end
			return vim.rpcrequest(jobid, method, ...)
		end

		-- Cache for later
		nvim[key] = result

		return result
	end
}


---Starts a new Neovim process, returns the handle.
---@param jobopts table?  Optional job options
---@return table handle  The handle to the Neovim process
function M.start(jobopts)
	jobopts = jobopts or DEFAULT_JOBOPTS
	jobopts.rpc = true
	local jobid = vim.fn.jobstart(COMMAND, jobopts)

	if jobid == 0 then
		local msg = INV_ARGS_TEMPLATE:format(vim.inspect(jobopts))
		error(msg)
	elseif jobid == -1 then
		local msg = INV_CMD_TEMPLATE:format(COMMAND[1])
		error(msg)
	end

	local result = setmetatable({}, mt)
	channels[result] = jobid

	return result
end


function M.connect(jobid)
	local result = setmetatable({}, mt)
	channels[result] = jobid
	return result
end


---Stops the process behind the given handle.
---@param nvim table  The Neovim process handle
---@param timeout integer?  Timeout in milliseconds
---@return integer status  Same as the first return value of jobwait()
function M.stop(nvim, timeout)
	local channel = channels[nvim]
	vim.rpcnotify(channel, 'nvim_cmd', {cmd = 'quitall', bang = true}, {})

	local result
	if timeout then
		result  = vim.fn.jobwait({channel}, timeout)
	else
		result = vim.fn.jobwait({channel})
	end
	return result[1]
end

return M
