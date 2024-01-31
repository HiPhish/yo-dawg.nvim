.. default-role:: code

#########
 Yo-Dawg
#########

   Yo dawg, I heard you like Neovim, so I put a Neovim inside your Neovim so
   you can edit while you edit.

This is a thin wrapper plugin for Neovim that cuts down on the boilerplate code
for controlling an embedded Neovim process inside Neovim.  Why would you want
to do that?  For me it's about testing, if I write my tests in Busted_ I need
to test the plugin code in a separate Neovim process which is distinct from the
process running the test.  This is not limited to testing though, it's a
general purpose-plugin.  Think of it like Selenium_ for Neovim.


Installation and configuration
##############################

Install it like any other Neovim plugin.  There is no configuration, this is
purely a library.  Personally I like to install it as an optional plugin
(`:h :packadd`), but that's up to you.


Usage
#####

Here is a simple toy example:

.. code:: lua

   local yd = require 'yo-dawg'

   -- Start a new process using the default job options
   local nvim = yd.start()

   -- Evaluate a Vim script expression
   local result = nvim:eval('1 + 2')
   -- Call an asynchronous method (does not wait for a result)
   nvim:async_set_var('my_var', result)
   -- Only synchronous methods can return values
   local my_var = nvim:get_var('my_var')

   -- Terminate the Neovim process when done
   yd.stop(nvim)

Any Neovim API method (`:h API`) can be called as a method.  To call the method
asynchronously prefix it with `async_`.  This plugin is forwards compatible,
any new method will automatically be supported.


Status of the plugin
####################

It's done as far as I am concerned.  It does one thing and does it well.


License
#######

Licensed under the terms of the MIT (Expat) license.  See the LICENSE_ file for
details.


.. _Busted: https://lunarmodules.github.io/busted/
.. _Selenium: https://www.selenium.dev/
.. _LICENSE: LICENSE.txt
