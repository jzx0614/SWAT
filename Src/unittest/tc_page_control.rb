$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..") 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..\libs')
require "test/unit"
require "page_control"

class PageControlTest < Test::Unit::TestCase
    
    def setup
        @pageControl = PageControl.new('Router', '192.168.80.206')
    end
    
    def teardown
        @pageControl.close
    end
    
    def test_goto_next_report_page
        while @pageControl.goto_next_report_page 
        end
    end
    
    def test_set_filter_rule
        @pageControl.set_filter_rules(['TopN'], ['Breakdown'])
        while @pageControl.goto_next_report_page 
        end        
    end
   
end

