-- SPDX-FileCopyrightText: © 2024 Alejandro "HiPhish" Sanchez
-- SPDX-License-Identifier: Unlicense

local yd = require 'yo-dawg'


describe('Startup and shutdown', function()
	local nvim

	describe('Faulty startup', function()
		it('Raises an error on invalid arguments', function()
			local jobstart = vim.fn.jobstart
			local function fake_jobstart(_cmd, _jobopts)
				return 0
			end

			assert.has_error(function()
				vim.fn.jobstart = fake_jobstart
				nvim = yd.start()
			end)
			vim.fn.jobstart = jobstart
			assert.is_nil(nvim)
		end)

		it('Raises an error on not executable command', function()
			local jobstart = vim.fn.jobstart
			local function fake_jobstart(_cmd, _jobopts) return -1 end

			assert.has_error(function()
				vim.fn.jobstart = fake_jobstart
				nvim = yd.start()
			end)
			vim.fn.jobstart = jobstart
			assert.is_nil(nvim)
		end)
	end)

	describe('Happy path', function()
		it('Starts up and shuts down without error', function()
			nvim = yd.start()
			yd.stop(nvim)
		end)

		it('Is raises an error when we try to stop a stopped process', function()
			nvim = yd.start()
			yd.stop(nvim)
			assert.has_error(function()
				yd.stop(nvim)
			end)
		end)

		it('Shuts down with generous timeout', function()
			nvim = yd.start()
			yd.stop(nvim, 250)
		end)

		it('Applies custom job options', function()
			local key = 'XXX_FOO_XXX'
			nvim = yd.start{env = {[key] = 'foo'}}
			local value = nvim:exec_lua('return os.getenv(...)', {key})
			assert.is.equal('foo', value)
			yd.stop(nvim)
		end)
	end)
end)
