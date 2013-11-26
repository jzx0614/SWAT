$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..") 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..\libs')
require "test/unit"
require "export_table"

class ExportTableTest < Test::Unit::TestCase
    
    def setup
        @export_table = ExportTable.new
    end
    
    def teardown

    end
    
    def test_load_one_table
        result = @export_table.load_one_table("Router_Detail_P1", "../../basic_traffic_report/expect_table")
        result.each {|row| puts row.to_s}
        
        result = @export_table.load_one_table("Router_Breakdown_bps", "../../basic_traffic_report/expect_table")
        result.each {|row| puts row.to_s}                
    end

    def test_load_two_table
        result = @export_table.load_two_table("Router_TopN_Probe_bps", "../../basic_traffic_report/expect_table")
        result.each do |table| 
            table.each{|row| puts row.to_s}
        end
    end
    
    def test_export_one_table_to_excel
        table1 = [["", "IP Address(Destination)"], ["IP Address(Source)", "6:a:b:65::3", "6:a:0:65::2", "6:a:b:66::3", "6:a:b:67::3", "6:a:b:68::3", "6:a:b:69::3", "6:a:b:6a::3", "6:a:b:6b::3", "6:a:b:6c::3", "6:a:b:6d::3", "6:a:b:6e::3", "6:a:b:6f::3", "10.11.101.3", "10.0.101.2", "10.11.102.3", "6:a:b:70::3", "10.11.103.3", "6:a:0:65::8", "10.11.104.3", "6:a:b:71::3", "10.11.105.3", "10.11.106.3", "6:a:b:72::3", "10.11.107.3", "10.11.108.3", "6:a:b:73::3", "10.11.109.3", "10.11.110.3", "Comment"], ["40.04K", "-", "38.09K", "36.13K", "34.18K", "32.23K", "30.27K", "28.32K", "26.37K", "24.41K", "22.46K", "20.51K", "-", "-", "-", "18.55K", "-", "-", "-", "16.60K", "-", "-", "14.65K", "-", "-", "12.70K", "-", "-"], ["-", "38.09K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "36.13K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "34.18K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "32.23K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "30.27K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "28.32K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "26.37K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "24.41K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "22.46K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "20.51K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "20.02K", "-", "19.04K", "-", "18.07K", "-", "17.09K", "-", "16.11K", "15.14K", "-", "14.16K", "13.18K", "-", "12.21K", "11.23K"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "19.04K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "18.55K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "18.07K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "17.58K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "17.09K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "16.60K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "16.11K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "15.14K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "14.65K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "14.16K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "13.18K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "12.70K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "12.21K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "11.23K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "10.74K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"]]
        table2 = [["", "IP Address(Destination)"], ["IP Address(Source)", "6:a:b:65::3", "6:a:0:65::2", "6:a:b:66::3", "6:a:b:67::3", "6:a:b:68::3", "6:a:b:69::3", "6:a:b:6a::3", "6:a:b:6b::3", "6:a:b:6c::3", "6:a:b:6d::3", "6:a:b:6e::3", "6:a:b:6f::3", "10.11.101.3", "10.0.101.2", "10.11.102.3", "6:a:b:70::3", "10.11.103.3", "6:a:0:65::8", "10.11.104.3", "6:a:b:71::3", "10.11.105.3", "10.11.106.3", "6:a:b:72::3", "10.11.107.3", "10.11.108.3", "6:a:b:73::3", "10.11.109.3", "10.11.110.3", "Comment"], ["40.04K", "-", "38.09K", "36.13K", "34.18K", "32.23K", "30.27K", "28.32K", "26.37K", "24.41K", "22.46K", "20.51K", "-", "-", "-", "18.55K", "-", "-", "-", "16.60K", "-", "-", "14.65K", "-", "-", "12.70K", "-", "-"], ["-", "38.09K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "36.13K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "34.18K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "32.23K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "30.27K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "28.32K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "26.37K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "24.41K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "22.46K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "20.51K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "20.02K", "-", "19.04K", "-", "18.07K", "-", "17.09K", "-", "16.11K", "15.14K", "-", "14.16K", "13.18K", "-", "12.21K", "11.23K"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "19.04K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "18.55K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "18.07K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "17.58K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "17.09K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "16.60K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "16.11K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "15.14K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "14.65K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "14.16K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "13.18K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "12.70K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "12.21K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "11.23K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"], ["-", "10.74K", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"]]

        @export_table.export_diff_one_table('testxls', table1, table2, {:current=>[[13],[2,2],[14,13]], :expect=>['Error', [13],[2,2],[14,13]]}) 
    end
end

