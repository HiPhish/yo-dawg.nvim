-- SPDX-License-Identifier: Unlicense
-- SPDX-FileCopyrightText: © 2026 HiPhish

local yd = require 'yo-dawg'

describe('The with-cmd function', function ()
	it('instantiates a new table', function()
		local custom_yd = yd:with_cmd({})
		assert.equals('table', type(custom_yd))
		assert.are_not_equal(yd, custom_yd)
	end)

	it('contains the command', function()
		local cmd = {'foo', 'bar', 'baz'}
		local custom_yd = yd:with_cmd(cmd)
		assert.are_equal(cmd, custom_yd.cmd)
	end)

	it('contains the stop function', function()
		local cmd = {'foo', 'bar', 'baz'}
		local custom_yd = yd:with_cmd(cmd)
		assert.is_not_nil(custom_yd.stop)
	end)

	it('calls jobstart with the custom command', function()
		local job_cmd = nil
		local function fake_jobstart(cmd, _jobopts)
			job_cmd = cmd
		end
		local real_jobstart = vim.fn.jobstart
		local cmd = {'foo', 'bar', 'baz'}
		local custom_yd = yd:with_cmd(cmd)
		pcall(function()
			vim.fn.jobstart = fake_jobstart
			custom_yd.start({})
		end)
		vim.fn.jobstart = real_jobstart
		assert.are_equal(cmd, job_cmd)
	end)

	it('can start a Neovim process', function()
		local custom_yd = yd:with_cmd {
			vim.v.progpath, '--embed', '--headless'
		}
		local nvim
		pcall(function ()
			nvim = custom_yd.start()
			-- The value does not matter, only that the embedded Neovim works
			assert.are_equal(13, nvim:eval('13'))
		end)
		yd.stop(nvim)
	end)
end)
