-- SPDX-FileCopyrightText: © 2024 Alejandro "HiPhish" Sanchez
-- SPDX-License-Identifier: Unlicense

local yd = require 'yo-dawg'


describe('Connecting to an already running process', function()
	local process

	before_each(function()
		process = vim.fn.jobstart({'nvim', '--embed', '--headless'}, {rpc = true})
	end)

	describe('Manually shut down the process', function()
		after_each(function()
			vim.rpcnotify(process, 'nvim_cmd', {cmd = 'quitall', bang = true}, {})
			vim.fn.jobwait({process})
		end)

		it('Can connect to an already existing Neovim process', function()
			local nvim = yd.connect(process)
			local result = nvim:eval('1 + 2')
			assert.is.equal(3, result)
		end)
	end)

	it('Can be shut down explicitly', function()
		local nvim = yd.connect(process)
		yd.stop(nvim)
	end)
end)
