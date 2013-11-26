$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..") 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..\libs')
require "test/unit"
require "browser_operator"

class BrowserOpraterTest < Test::Unit::TestCase
    def setup
        @website = '192.168.80.206'
        @browser = BrowserOperator.instance
    end
    
    def teardown
        @browser.close
    end
    
    def test_singleton
        assert_raise(NoMethodError){BrowserOperator.new}
        assert_equal(BrowserOperator.instance.object_id, @browser.object_id)
    end

    def test_login_without_password
        assert_equal @browser.login(@website, 'admin'), true 
        assert_equal(@browser.browser.table(:id, 'table_html_body').exist?, true)
    end
    
    def test_login_with_password
        assert_equal(@browser.login(@website, 'fail_user'), false)
    
        assert_equal(@browser.login(@website, 'admin', 'admin'), true)
        assert_equal(@browser.browser.table(:id, 'table_html_body').exist?, true)
    end
    
    def test_get_report_panel
        puts '[BrowserOpraterTest] test test_get_report_panel'
        @browser.login(@website, 'admin')
        assert_equal @browser.get_report_panel.exist?, true        
    end
    
    def test_get_case_panel
        puts '[BrowserOpraterTest] test test_get_case_panel'
        @browser.login(@website, 'admin')
        assert_equal @browser.get_case_panel.exist?, true
    end

    def test_get_counter_table
        puts '[BrowserOpraterTest] test test_get_counter_panel'
        @browser.login(@website, 'admin')
        @browser.browser.span(:id, 'lmenu_10102').click
        assert_equal @browser.get_counter_table.exist?, true
    end

    def test_get_data_flow_panel
        puts '[BrowserOpraterTest] test test_get_data_flow_panel'
        @browser.login(@website, 'admin')
        @browser.browser.span(:id, 'lmenu_10113').click
        assert_equal @browser.get_data_flow_table.exist?, true
    end
    
    def test_get_flow_table_matrix
        puts '[BrowserOpraterTest] test test_get_flow_table_matrix'
        @browser.login(@website, 'admin')
        @browser.browser.span(:id, 'lmenu_10106').click
        assert_equal @browser.get_flow_table_matrix.exist?, true
    end  
    
end

