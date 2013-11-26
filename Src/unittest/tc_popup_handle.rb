# encoding: big5
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..") 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..\libs')
require "test/unit"
require "browser_operator"
require "rautomation"
require "popup_handle"

class PopupHandleTest < Test::Unit::TestCase
    
    def setup
        @browserOperator = BrowserOperator.instance
        @browserOperator.login('192.168.80.206', 'admin')
        
        @browser = @browserOperator.browser
    end
    
    def teardown
        @browserOperator.close
    end
    
    def test_download_xml
        @browser.span(:id, 'lmenu_10103').click
        @browser.button(:id, "DownloadXMLBtn").click
        PopupHandle.deal_download_dialog('test.xml')
    end
end

