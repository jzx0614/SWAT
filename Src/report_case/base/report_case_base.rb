require "browser_operator"
require "report_key_control"
require "fetch_table"
require "parse_file"
require "export_table"
require "compare_table"
require "popup_handle"

def create_report_case page_name
    obj_name, report_name = page_name.split(" > ")[-2..-1]
    case report_name
    when 'Detail'
        if obj_name == 'Neighbor'
            require 'report_case/neighbor_detail_case'
            report_case = NeighborDetailCase.new(obj_name, report_name)
        else
            require 'report_case/detail_case'
            report_case = DetailCase.new(obj_name, report_name)
        end
    when 'Compare'
        require 'report_case/compare_case'
        report_case = CompareCase.new(obj_name, report_name)
    when 'Summary Report'
        require 'report_case/summary_report_case'
        report_case = SummaryReportCase.new(obj_name, report_name)
    when 'Peering Analysis'
        require 'report_case/peering_analysis_case'
        report_case = PeeringAnalysisCase.new(obj_name, report_name)
    when 'Breakdown'
        require 'report_case/breakdown_case'
        report_case = BreakdownCase.new(obj_name, report_name)
    when 'TopN'
        require 'report_case/topn_case'
        report_case = TopNCase.new(obj_name, report_name)
    when 'Matrix'
        require 'report_case/matrix_case'
        report_case = MatrixCase.new(obj_name, report_name)
    else
        puts '[create_report_case] no match any report type'
        report_case = nil
    end
    report_case
end

class ReportCaseBase
    def initialize obj_name, report_name
        @obj_name = obj_name
        @report_name = report_name
        
        @browserOperator = BrowserOperator.instance
        @report_key_control = ReportKeyContrl.new
        @compareTable = CompareTable.new
        
        @export_table = nil
        @export_mode = ''
        collect_key()
    end
    
    # set_export_mode('rpt' or 'expect')
    # setting the directory of export file 
    def set_export_mode mode
        @export_mode = mode
    end
    
    # go to next test case
    def goto_next_case
        @report_key_control.goto_next_case
    end
    
    # fetch current test table
    def fetch_curr_table
        Array.new
    end

    # fetch expect value from file
    def fetch_expect_table dir
        result = export_table.load_one_table(get_case_name(), dir)
    end    
    
    # compare_table(ary, ary) > true or false
    # compare current table and expect table
    def compare_table current_table, expect_table
        @compareTable.compare_table(current_table, expect_table)
    end
    
    # download_csv(String, Bool)
    # click DownloadCSV button, and save to directory
    # Parameter:
    #   dir     csv will save directory path
    #   expect  if expect is true, filename will add string "_(expect)". else filename will case name
    def download_csv dir, expect=false 
        browser = @browserOperator.browser
        csv_btn = browser.button(:id, "DownloadCsvBtn")
	 
        raise Watir::Exception::UnknownObjectException if !csv_btn.visible? 
            
        browser.radio(:value, 'time_range').click
        today = Date.today().strftime('%Y/%m/%d')
        end_hour = Time.now()
        end_time = '%02d:00' % end_hour.hour
        start_time = '%02d:00' % (end_hour - 60*60).hour
        
        
        js_string = "document.getElementById('StartDateInput').value = '#{today}';
        document.getElementById('StartTimeInput').value = '#{start_time}';
        document.getElementById('EndDateInput').value = '#{today}';
        document.getElementById('EndTimeInput').value = '#{end_time}';"
        
        browser.execute_script(js_string)
        browser.button(:value, 'Submit').click
        @browserOperator.wait_loading()
        
        case_name = get_case_name() 
        puts '[ReportCaseBase] %s Download CSV' % case_name
        csv_btn.click
        
        if expect
            filename = case_name.gsub(/[\\\/:\*\?<>|\"]/, '') << '_(expect).csv'
        else
            filename = case_name.gsub(/[\\\/:\*\?<>|\"]/, '') << '.csv'
        end        
        file_path = File.join(dir, filename)
        
        PopupHandle.deal_download_dialog(file_path)
        
        waitting_download_finish(file_path)
    end
    
    # download_XML(String, Bool)
    # click DownloadXML button, and save to directory
    # Parameter:
    #   dir         csv will save directory path
    #   expect      if expect is true, filename will add string "_(expect)". else filename will case name
    def download_xml dir, expect=false
        browser = @browserOperator.browser
        xml_btn = browser.button(:id, "DownloadXMLBtn")
		
        raise Watir::Exception::UnknownObjectException if !xml_btn.visible?
       		        
        browser.radio(:value, 'period').click
        browser.button(:value, 'Submit').click
        @browserOperator.wait_loading()
        
        xml_btn.click
        
        case_name = get_case_name()
        puts '[ReportCaseBase] %s download XML' % case_name
        if expect
            filename = case_name.gsub(/[\\\/:\*\?<>|\"]/, '') << '_(expect).xml'
        else
            filename = case_name.gsub(/[\\\/:\*\?<>|\"]/, '') << '.xml'
        end
        file_path = File.join(dir, filename)
        
        PopupHandle.deal_download_dialog(file_path)
        waitting_download_finish(file_path)
    end
    
    # compare_xml(String, String) > true of fase
    # compare expect and current xml
    # Parameter:
    #   current_dir     the directory of current xml file
    #   expect_dir      the directory of expect xml file
    def compare_xml current_dir, expect_dir
        case_name = get_case_name() 
        puts '[ReportCaseBase] compare_xml ' << case_name

        expect_file_name = File.join(expect_dir, case_name.gsub(/[\\\/:\*\?<>|\"]/, '') + '_(expect).xml')
        raise "%s isn't exist." % expect_file_name if !File.exist?(expect_file_name)
        expect_xml = ParseFile.parser_xml_by_filename(expect_file_name)
        
        current_file_name = File.join(current_dir, case_name.gsub(/[\\\/:\*\?<>|\"]/, '') + '.xml')
        raise "%s isn't exist." % current_file_name if !File.exist?(current_file_name)
        current_xml = ParseFile.parser_xml_by_filename(current_file_name)
        
        result = true
        expect_xml.each_key do |flow_type|
            expect = expect_xml[flow_type]
            current = current_xml[flow_type]
            result &= compare_xml_method(current, expect)
        end
        result        
    end
    
    # compare_csv(String, String) > true of fase
    # compare expect and current csv
    # Parameter:
    #   current_dir     the directory of current csv file
    #   expect_dir      the directory of expect csv file
    def compare_csv current_dir, expect_dir
        case_name = get_case_name()
        puts '[CompareFile] compare_csv ' << case_name

        expect_file_name = File.join(expect_dir, case_name.gsub(/[\\\/:\*\?<>|\"]/, '') + '_(expect).csv')
        raise "%s isn't exist." % expect_file_name if !File.exist?(expect_file_name)
        expect_csv = ParseFile.parser_csv_by_filename(expect_file_name)
        
        current_file_name = File.join(current_dir, case_name.gsub(/[\\\/:\*\?<>|\"]/, '') + '.csv')

        raise "%s isn't exist." % current_file_name if !File.exist?(current_file_name)
        current_csv = ParseFile.parser_csv_by_filename(current_file_name)
        
        result = (expect_csv == current_csv)
    end
    
    # compare_xml_methond(2D Array, 2D Array) > true of false
    # it will implement method to compare xml result
    # Parameter:
    #   current     2D Array, it is current xml result
    #   expect      2D Array, it is expect xml result
    def compare_xml_method current, expect
        @compareTable.compare_table(current, expect)
    end 
    
    # get current test case name
    def get_case_name
        case_name = ([@obj_name, @report_name] + @report_key_control.get_key_list).join('_')
    end
    
    # export table to file 
    def export_table_to_file(table)
        export_table.export_one_table(get_case_name(), table)
    end
    
    # export_diff_table_to_file(current, expect)
    # export current value and expect value to xls when compare false
    # Parameter:    
    #   current     2D Array, it is current result
    #   expect      2D Array, it is expect result
    def export_diff_table_to_file(current, expect)
        error_list = @compareTable.get_error()
        export_table.export_diff_one_table(get_case_name(), current, expect, error_list)
    end
    
    protected
        # collect all key to permutation all test case
        def collect_key
            # case_panel = @browserOperator.get_case_panel
            # @report_key_control.insert_key(SelectListKey.new(case_panel, 'periodSelect'))
        end
        
    private
        # lazy create class ExportTable
        def export_table
            if @export_table.nil?
                @export_table = ExportTable.new(@export_mode)
            end
            @export_table
        end
        
        def waitting_download_finish filename
            time_out = 10
            
            begin
                Timeout::timeout(time_out) do
                    sleep(0.5) until File.exist?(filename)
                    return
                end
            rescue Timeout::Error
                puts "[Report_case_base] Waitting Download %s TimeOut " % filename
                raise
            end
        end
end