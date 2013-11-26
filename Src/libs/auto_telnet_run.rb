require 'net/telnet'
require 'parseconfig'

class AutomationTelnet
	def initialize
		@telnet = nil
		@setting = ParseConfig.new('setting.ini')
		@anomaly = @setting.params['script']['ATD']
		@bt = @setting.params['script']['Basic_Traffic']
		@sf = @setting.params['script']['Server-farm']
		@ss = @setting.params['script']['Snapshot']
	end

	def auto_telnet telnet_ip
		puts "[AutomationTelnet] Telnet ATM"
		@telnet = Net::Telnet::new("Host" => "#{telnet_ip}", "Prompt" => /[$%#>] \z/, "Timeout" => 10)
	end
	
	def auto_telnet_login username, password
		puts "[AutomationTelnet] Telnet auto login"
		@telnet.login("#{username}", "#{password}") { |idx| print idx}
	end
	
	def change_enable_mode
		puts "[AutomationTelnet] change mode of enable mode"
		@telnet.puts("enable")
		@telnet.waitfor(/assword:/n) {|passwd| print passwd}
		@telnet.cmd({"String" => "default",
		             "Match" => /[$%#>] \z/n,
					 "Timeout" => 3}) {|passwd| print passwd}
	end
	
	def change_maintain_mode
		puts "[AutomationTelnet] change mode of maintain mode"
		@telnet.puts("atm_maintain_mode")
		@telnet.waitfor(/assword:/n) {|passwd| print passwd}
		@telnet.cmd({"String" => "genienrm", 
					 "Match" => /[$%#>] \z/n,
					 "Timeout" => 3}) {|passwd| print passwd}
	end
	
	def testing_script (test_case, telnet_ip, msp_ip=nil)
		case test_case
		when 'ATD'
			puts "[AutomationTelnet] Send Anomaly Flow"
			@telnet.cmd("cd #{@anomaly}\n") {|script| print script }
			@telnet.cmd("./nfv9_atd_traffic.sh 0 IntNeb_basis_anomaly.cfg #{telnet_ip} #{msp_ip} &") {|script| print script}
		when 'Basic Traffic'
			puts "[AutomationTelnet] Send Flow of Basic Traffic"
			@telnet.cmd("cd #{@bt}\n") {|script| print script }
			@telnet.cmd("./nfv9_basic_traffic.sh 0 nfv9_basic_traffic.cfg #{telnet_ip} &") {|script| print script }
		when 'Server-farm'
			puts "[AutomationTelnet] Send Flow of Server-farm"
			@telnet.cmd("cd #{@sf}\n") {|script| print script }
			@telnet.cmd("./nfv9_basic_traffic.sh 0 nfv9_bt_sf_bk.cfg #{telnet_ip} &") {|script| print script }
		when 'Snapshot'
			puts "[AutomationTelnet] Send Flow of Snapshot"
			@telnet.cmd("cd #{@ss}\n") {|script| print script }
			@telnet.cmd("./gen_traffic.pl ATM532_SUBNETWORK_traffic.cfg ATM532_SUBNETWORK_traffic.cfg log_ #{telnet_ip} &") {|script| print script }
			@telnet.cmd("./gen_sflow.pl gen_sflow.cfg log_ #{telnet_ip} &") {|script| print script }
		else
			puts "[AutomationTelnet] no match testing case: #{test_case}"
			exit
		end
		test_case
	end
end