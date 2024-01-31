-- SPDX-License-Identifier: MIT

local yd = require 'yo-dawg'


describe('Calling RPC methods', function()
	local nvim

	before_each(function()
		nvim = yd.start()
	end)

	after_each(function()
		yd.stop(nvim)
	end)

	it('Evaluates simple Vim script expressions', function()
		local result

		result = nvim:eval('1 + 2')
		assert.is.equal(3, result)

		result = nvim:eval('"Hello, " .. "world!"')
		assert.is.equal('Hello, world!', result)

		result = nvim:eval('[1, 2] + [3, 4]')
		assert.are.same({1, 2, 3, 4}, result)
	end)

	it('Performs side effect synchronously', function()
		nvim:set_var('my_var', 123)
		local my_var = nvim:get_var('my_var')
		assert.is.equal(123, my_var)
	end)

	it('Performs side effect asynchronously', function()
		nvim:async_set_var('my_var', 123)
		local my_var = nvim:get_var('my_var')
		assert.is.equal(123, my_var)
	end)

	it('Never returns a value asynchronously', function()
		local result = nvim:async_eval('1 + 2')
		assert.is_nil(result)
	end)

	it('Raises an error for unknown methods', function()
		assert.has_error(function()
			nvim:herp_derp_lol_rofl()
		end)
	end)
end)
