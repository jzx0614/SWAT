$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..") 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..\libs')
require "test/unit"
require "parse_file"

class ParseFileeTest < Test::Unit::TestCase
    
    def setup
    end
    
    def teardown
        # @browserOperator.close
    end

    def test_compare_csv
        ParseFile.parser_csv_by_filename('..\..\basic_traffic_report\Expect_Download_CSV_XML\Router_TopN_PE4_bps_(expect).csv')
    end
    
    def test_compare_xml
        ParseFile.parser_xml_by_filename('..\..\basic_traffic_report\Expect_Download_CSV_XML\Sub-Network_Breakdown_Protocol_bps_(expect).xml')
        ParseFile.parser_xml_by_filename('..\..\basic_traffic_report\Expect_Download_CSV_XML\Router_Breakdown_pps_(expect).xml')
    end
end

