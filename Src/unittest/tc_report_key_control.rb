$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..") 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..\libs')
require "test/unit"
require "report_key_control"
require "browser_operator"

class ReportKeyContrlTest < Test::Unit::TestCase
    
    def setup
        @browserOperator = BrowserOperator.instance
        @browserOperator.login('192.168.80.206', 'admin')
        
        browser = @browserOperator.browser
        browser.span(:id, 'lmenu_10244').click
        
        @report_key_control = ReportKeyContrl.new()
    end
    
    def teardown
        @browserOperator.close
    end
    
    def test_insert_key
        case_panel = @browserOperator.get_case_panel()
        @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_ins_value'))
        @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_topn_value'))
        @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_counter_value', ['bps', 'pps']))
        #@report_key_control.insert_key(SelectListKey(case_panel, 'topn_field_depth_select'))
    end
    
    def test_get_key_list
        @report_key_control.get_key_list()
        
        test_insert_key()
        @report_key_control.get_key_list()
    end
    
    def test_goto_next_case
        test_insert_relation_keys
        while @report_key_control.goto_next_case
            puts @report_key_control.get_key_list.to_s
        end
    end
    
    def test_insert_relation_keys
        case_panel = @browserOperator.get_case_panel()
        @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_ins_value'))
        
        top_n = SelectListKey.new(case_panel, 'rpt_topn_value')
        counter = SelectListKey.new(case_panel, 'rpt_counter_value')
        @report_key_control.insert_relation_keys([top_n, counter])
    end    
end

