path = require 'path'
os = require 'os'

gyp = require('node-gyp')()

# The first two arguments are apparently necessary as else nopt won’t include
# loglevel as an option.
defaultArgv = ['node', '.', '--loglevel=silent']
defaultDevDir = path.join os.homedir(), '.node-gyp'

# It is necessary to execute rebuild manually as calling node-gyp’s rebuild
# programmatically fires the callback function too early.
manualRebuild = (callback) ->
	gyp.commands.clean [], (error) ->
		return callback(error) if error

		gyp.commands.configure [], (error) ->
			return callback(error) if error

			gyp.commands.build [], callback

module.exports = (grunt) ->
	grunt.registerMultiTask 'gyp', 'Run node-gyp commands from Grunt.', ->
		done = @async()

		options = @options
			debug: false

		argv = defaultArgv.slice()

		# If we do not push '--no-debug' node-gyp might keep the debug option on
		# as it was set on an earlier run.
		if options.debug then argv.push '--debug' else argv.push '--no-debug'

		if options.arch then argv.push "--arch=#{options.arch}"

		if options.directory then argv.push "--directory=#{options.directory}"
		
		gyp.parseArgv argv

		gyp.devDir = defaultDevDir

		gypCallback = (error) -> if error then done(error) else done()

		@data.command = 'rebuild' if !@data.command

		switch @data.command
			when 'clean'     then gyp.commands.clean [], gypCallback
			when 'configure' then gyp.commands.configure [], gypCallback
			when 'build'     then gyp.commands.build [], gypCallback
			when 'rebuild'   then manualRebuild gypCallback
