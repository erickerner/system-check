# File: system-check.rb
#		Execute system commands, create report, and email report
#		Set root directory, commands, and contacts in config.yml
#		Results of commands are written to archive/system-stats-YYYY.MM.DD-HH:MM:SS.txt
# 

# =============================================================================
require 'date'
require 'yaml'

# =============================================================================
# Helper functions
# =============================================================================
# Get current date and time. Format as YYYYMMDD-HHMMSS
#
# DateTime.now.to_s => formatted as YYYY-MM-DDTHH:MM:SS-HH:MM
#		Example: "2011-10-05T12:52:37-05:00"
#
# .sub(/-\d{2}:\d{2}/, "") removes the UTC comparison at end of string
def now
	DateTime.now.strftime.sub(/-\d{2}:\d{2}/, "").gsub("-", ".").sub("T", "-").gsub(":", "")
end

# =============================================================================
# Environment/location helper
# =============================================================================
if File.exists? 'config.yml'
	config = YAML::load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'config.yml'))
	root = config["root"]
	commands = config["commands"]
	contacts = config["contacts"]
else
	puts "Missing config.yml. Use config.yml.example as a template."
	exit
end

# =============================================================================
# Logger helper
# =============================================================================
logfile = "#{root}/log/production.log"
log = File.open(logfile, 'a')

# =============================================================================
# Logging start
# =============================================================================
EXEC_START = now
HOST = `uname -n`
USER = `whoami`

log.puts "I| LOGSTART: #{EXEC_START}"
log.puts "I| AppRoot: #{root}"
log.puts "I| Host: #{HOST}"
log.puts "I| User: #{USER}"

# =============================================================================
# Execute commands and create report
# =============================================================================
outfile = "#{root}/archive/system-check-" + EXEC_START.to_s + ".txt"
os = File.open(outfile, 'w')

os.puts "-- System Check --"
os.puts
os.puts "Host: #{HOST}"
os.puts "Execution Date: #{EXEC_START}"
os.puts "Archive: #{outfile}"

log.puts "I| Executing commands and writing results to #{outfile}"

# Execute command and write results to report unless line is a comment or blank
commands.each do |c|
	begin
		os.puts "\n# ============================================================================="
		os.puts "# #{c}"
		os.puts "# ============================================================================="
		os.puts `#{c}`
	rescue StandardError => e
		message = "Error executing [#{c}]"
		log.puts "E| #{message}"
		os.puts message
		puts message
	end
end

os.close

# =============================================================================
# Email report
# =============================================================================
log.puts "I| Emailing #{outfile} to #{contacts.join(',')}"
`perl #{root}/script/mail.pl "System Check" #{outfile} #{contacts.join(',')} syscheck-no-reply`

# =============================================================================
# Logging end
# =============================================================================
log.puts "I| LOGEND:   #{now}" # The extra space is so it lines up with LOGSTART time
log.puts "\n\n\n" # Separate from next log entry
log.close

