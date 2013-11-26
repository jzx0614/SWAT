$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..") 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..\libs')
require "test/unit"
require "browser_operator"
require "fetch_table"

class FetchTableTest < Test::Unit::TestCase
    
    def setup
        @browserOperator = BrowserOperator.instance
        @browserOperator.login('192.168.80.206', 'admin')
        
        @browser = @browserOperator.browser
    end
    
    def teardown
        @browserOperator.close
    end

    def test_parser_counter_table
        @browser.span(:id, 'lmenu_10102').click
        
        counter_table = @browser.table(:id, 'DetailCounterTable_Average').when_present
        result = FetchTable.parser_counter_table(counter_table, multiple=true)
        assert_equal(result.length,  2)
        assert_equal(result[0],  ["bps", "pps", "CPU Usage%", "Memory Usage%"])
        assert_equal(result[1].length,  4)
    end

    def test_parser_data_flow_table
        @browser.span(:id, 'lmenu_10113').click
        data_flow_table = @browser.table(:id, 'DataFlowTable')

        result = FetchTable.parser_data_flow_table(data_flow_table, 'Last')
        result.each{ |row| puts row.to_s }
        
        assert_equal(result[0], ["All", "Interface Object", "Input", "Input %", "Output", "Output %", "Sum", "Total %"])
    end
    
    def test_parser_flow_table_matrix
        @browser.span(:id, 'lmenu_10105').click
        flow_table_matrix = @browser.div(:class, 'sData')
        data_flow_table = flow_table_matrix.table(:id, 'DataFlowTable')

        result = FetchTable.parser_flow_table_matrix(data_flow_table, 'Last')
        result.each{ |row| puts row.to_s }
    end
    
    def test_parser_peering_table
        @browser.span(:id, 'lmenu_10212').click
        
        data_flow_table = @browser.table(:id, 'DataFlowTable')
        result = FetchTable.parser_data_flow_table(data_flow_table, 'Last')
        result.each{ |row| puts row.to_s }
    end
    
end

