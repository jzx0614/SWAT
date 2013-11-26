$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..") 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..\libs')
require "test/unit"
require "compare_table"
require "export_table"
require "browser_operator"
require 'fetch_table'

class ComareTableTest < Test::Unit::TestCase
    
    def setup
        @export_table = ExportTable.new
        @compare_table = CompareTable.new
        
        @browserOperator = BrowserOperator.instance
        @browserOperator.login('192.168.80.206', 'admin')
        
        @browser = @browserOperator.browser        
    end
    
    def teardown
        @browserOperator.close
    end
    
    def test_compare_detail
        expect_table = @export_table.load_one_table("Router_Detail_P1", "../../basic_traffic_report/expect_table")

        @browser.span(:id, 'lmenu_10102').click
        @browserOperator.wait_loading()
        
        case_panel = @browserOperator.get_case_panel()
        
        case_panel.select_list(:id, 'rpt_ins_value').select('P1')
        case_panel.button(:value, 'Submit').click
        @browserOperator.wait_loading()

        counter_div = @browserOperator.get_counter_table()
        last_table = counter_div.table(:id, 'DetailCounterTable_Last')
        
        
        current_table = FetchTable.parser_counter_table(last_table, multiple=true) 
        
        assert_equal(@compare_table.compare_table(current_table, expect_table), true)
    end

    def test_compare_breakdown_table
        expect_table = @export_table.load_one_table("Router_Breakdown_bps", "../../basic_traffic_report/expect_table")
        
        
        puts expect_table.to_s
        puts '--' * 10
        
        @browser.span(:id, 'lmenu_10105').click
        @browserOperator.wait_loading()
        
        case_panel = @browserOperator.get_case_panel()
        
        case_panel.select_list(:id, 'rpt_counter_value').select('bps')
        case_panel.button(:value, 'Submit').click
        @browserOperator.wait_loading()

        data_flow_table = @browserOperator.get_flow_table_matrix()
        current_table = FetchTable.parser_flow_table_matrix(data_flow_table, 'Last')
        
        assert_equal(@compare_table.compare_matrix(current_table, expect_table), true)
    end

    def test_compare_topn_table
        expect_table = @export_table.load_two_table("Interface_TopN_PE4.IF11_Application_pps", "../../basic_traffic_report/expect_table")
        
        @browser.span(:id, 'lmenu_10114').click
        @browserOperator.wait_loading()
        
        case_panel = @browserOperator.get_case_panel()
        
        case_panel.select_list(:id, 'rpt_ins_value').select('PE4.IF11')
        case_panel.select_list(:id, 'rpt_topn_value').select('Application')
        case_panel.select_list(:id, 'rpt_counter_value').select('pps')
        
        case_panel.button(:value, 'Submit').click
        @browserOperator.wait_loading()

        current_table = Array.new(2)
        
        counter_div = @browserOperator.get_counter_table()
        current_table[0] = FetchTable.parser_counter_table(counter_div.tables[0])
        
        data_flow_table = @browserOperator.get_data_flow_table()
        current_table[1] = FetchTable.parser_data_flow_table(data_flow_table, 'Last')
        
        assert_equal(@compare_table.compare_topn(current_table[1], expect_table[1]), true)
    end
    
    def test_compare_matrix_table
        expect_table = @export_table.load_two_table("Router_Matrix_P1_pps", "../../basic_traffic_report/expect_table")
        
        @browser.span(:id, 'lmenu_10106').click
        @browserOperator.wait_loading()
        
        case_panel = @browserOperator.get_case_panel()
        
        case_panel.select_list(:id, 'rpt_ins_value').select('P1')
        case_panel.select_list(:id, 'rpt_counter_value').select('pps')
        
        case_panel.button(:value, 'Submit').click
        @browserOperator.wait_loading()

        current_table = Array.new(2)
        
        counter_div = @browserOperator.get_counter_table()
        current_table[0] = FetchTable.parser_counter_table(counter_div.tables[0])
        
        data_flow_table = @browserOperator.get_flow_table_matrix()
        current_table[1] = FetchTable.parser_flow_table_matrix(data_flow_table, 'Last')
        
        # puts current_table[1].to_s
        # puts expect_table[1].to_s
      
        assert_equal(@compare_table.compare_matrix(current_table[1], expect_table[1]), true)

        # puts current_table[1].to_s
        # puts expect_table[1].to_s        
    end
    
    def test_compare_peering_table
        expect_table = @export_table.load_one_table("Internet_Peering Analysis_bps", "../../basic_traffic_report/expect_table")
        
        @browser.span(:id, 'lmenu_10212').click
        @browserOperator.wait_loading()
        
        case_panel = @browserOperator.get_case_panel()
        case_panel.button(:value, 'Submit').click
        @browserOperator.wait_loading()

        data_flow_table = @browserOperator.get_data_flow_table()
        current_table = FetchTable.parser_data_flow_table(data_flow_table, 'Last')
        
        puts current_table.to_s
        puts expect_table.to_s
        
        
        assert_equal(@compare_table.compare_table(current_table, expect_table), true)
    end
end

