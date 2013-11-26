$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'libs')

require 'parseconfig'
require 'auto_telnet_run'

alias org_puts puts
def puts output_string    
    $output_file << output_string << "\n"
    org_puts output_string
end

def main
	setting = ParseConfig.new('setting.ini')
	telnet_ip = setting.params['Collector']['Collector_ip']
	username = setting.params['Collector']['Collector_username']
	password = setting.params['Collector']['Collector_password']
	msp_ip = setting.params['MSP']['MSP_ip']
	test_case = setting.params['page']['test_case']
	
	telnet = AutomationTelnet.new
	begin
		telnet.auto_telnet(telnet_ip)
		telnet.auto_telnet_login(username, password)
	rescue
		puts "[Error Message] No login: #{telnet_ip}"
		exit
	end
	telnet.change_enable_mode()
	telnet.change_maintain_mode()
	telnet.testing_script(test_case, telnet_ip, msp_ip)
end	


if __FILE__ == $0
    $output_file = File.new('../telnet.log', 'w')
    main()
    $output_file.close()
end