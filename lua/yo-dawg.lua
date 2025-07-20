-- SPDX-FileCopyrightText: © 2024 Alejandro "HiPhish" Sanchez
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
	---Allows API methods over RPC as if they were methods of the object.  The
	---`key` is translated to an API method name by prepending `nvim_`.
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
---
---The job options are the same as for the Vim function `jobstart`, except that
---`rpc` will always be forced on.  The result is a Lua object which acts as a
---proxy to the remote Neovim process.  We can call Neovim API methods as if
---they were methods of this object.  Example:
---
---```lua
----- Evaluate a Vim script expression
---local result = nvim:eval('1 + 2')
----- Call an asynchronous method (does not wait for a result)
---nvim:async_set_var('my_var', result)
----- Only synchronous methods can return values
---local my_var = nvim:get_var('my_var')
---```
---
---The remote process must be explicitly closed by calling the `stop` function,
---otherwise the remote process will not be cleaned up, causing a resource
---leak.
---
---```lua
---local yd = require 'yo-dawg'
---
---nvim = yd.start()
----- Wrap the call to make sure we clean up even if an error is thrown
---pcall(function()
---    print(nvim:eval('1 + 2'))
---end)
---yd.stop(nvim)
---```
---
---@param jobopts table?  Optional job options
---@return table neovim  The remote Neovim instance object
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
