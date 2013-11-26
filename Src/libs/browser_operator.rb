require 'singleton'
require 'watir'

# Handle login to summary page.
# Provide a browser object.
# Other about Watir function.
class BrowserOperator
    include Singleton
    attr_writer :report_root_name
    def initialize
        @website = nil
        @browser = nil
        @time_out = 10
        @report_root_name = 'Report'
    end
    
    def close
        @website = nil
        
        if !@browser.nil?
            @browser.close
            @browser = nil
        end
    end
    
    # browser() -> watir::IE
    # you can use browser.xxx to get browser obejct.
    def browser
        if @browser.nil?
            # puts '[BrowserOperator] Create Internet Explorer'
            @browser = Watir::Browser.new
            @browser.activate
        end
        @browser
    end
    
    # login(website, username, password = nil) > true or false
    # goto ATM Summary Page from login
    # Parameter:
    #   website    you want to go to IP Address of ATM.
    #   usename    your login user name.
    #   password   your login password.
    def login (website, username, password = nil)
        return true if @website == website and browser.hidden(:name, 'sno').exist?
        
        @website = website
        puts "[BrowserOperator] Login #{username} #{password}"
        if password.nil?
            result = login_from_online_session username
        else
            result = fill_login_information username, password
        end
            
        browser.table(:id, 'table_html_body').wait_until_present(@time_out) if result
        result        
    end
    
    # get_report_panel() -> html-obejct
    # get html object of get_report panel
    #  ------------------
    # |      |           |
    # |report|           |
    # |      |           |
    # |panel |           |
    # |      |           |
    #  ------------------
    def get_report_panel
        # report_panel = browser.span(:text, @report_root_name).when_present(@time_out).parent.parent
        report_panel = browser.span(:text, @report_root_name).parent.parent
    end

    # get_case_panel() -> html-obejct
    # get html object of case panel 
    #  ------------------
    # |      |           |
    # |      |           |
    # |      |case panel |
    # |      |           |
    # |      |           |
    #  ------------------    
    def get_case_panel
        # case_panel = browser.td(:id, 'tb_form_body').when_present()
        case_panel = browser.td(:id, 'td_main_content').when_present(@time_out)
    end

    # get_counter_table() -> html-obejct
    # get html object of counter table 
    #  ------------------
    # |  --------------  |
    # | | Couter Table | |
    # |  --------------  |
    # |  --------------  |
    # | |              | |
    # | |              | |
    # | |              | |
    # | |              | |
    # |  --------------  |
    #  ------------------   
    def get_counter_table
        counter_table = browser.div(:id, 'div_counter_panel').when_present(@time_out)
    end
    
    # get_data_flow_table() -> html-obejct
    # get html object of data flow table 
    #  ------------------
    # |  --------------  |
    # | |              | |
    # |  --------------  |
    # |  --------------  |
    # | |              | |
    # | |   Data Flow  | |
    # | |     Table    | |
    # | |              | |
    # |  --------------  |
    #  ------------------       
    def get_data_flow_table
        data_flow_table = browser.table(:id, 'DataFlowTable').when_present(@time_out)
    end
    
    # get_flow_table_matrix() -> html-obejct
    # only get table of Matrix or Breakdown
    def get_flow_table_matrix
        flow_table_matrix = browser.div(:class, 'sData').when_present(@time_out)
        data_flow_table = flow_table_matrix.table(:id, 'DataFlowTable')    
    end
    
    # wait_loading()
    # wait "Loading" disappear
    def wait_loading
        puts "[BrowserOperator] wait_loading" << '..' * 10
        browser.div(:id, 'pageLoading').wait_while_present()
    end
    
    private
        def login_from_online_session username
            online_session_url = "http://#{@website}/atm_system_access.denis"
            puts "[BrowserOperator] goto " << online_session_url
            browser.goto(online_session_url)
            
            begin
                use_id_obj = browser.td(:text, username)
                use_id_obj.parent.link(:text, 'atm_status_summary').click
                return true
            rescue Watir::Exception::UnknownObjectException => error
                puts error
                return false
            end
        end
        
        def fill_login_information username, password
            puts "[BrowserOperator] goto " << @website
            browser.goto(@website)
            
            browser.text_field(:name, 'username').value = username
            browser.text_field(:name, 'passwd').value = password   
            browser.button(:id, 'img_submit').click
            
            begin 
                message_window = Watir::IE.find(:title, 'ATM Message Window')
                if (message_window)
                    puts "[BrowserOperator] There is a message window"
                    begin
                        message_window.link(:text, /Kick the user out and force into system/).click
                    rescue Watir::Exception::UnknownObjectException
                        
                    end
                else
                    sleep(0.5)
                end
            end until browser.hidden(:name, 'sno').exist?
            true
        end
end