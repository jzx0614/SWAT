$LOAD_PATH.unshift File.dirname(__FILE__) 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'libs')

require 'fileutils'
require 'parseconfig'
require 'page_control'
require 'report_case/base/report_case_base'
require 'report_summary'

# 
# Function  : download_xml_csv_main.rb
# Parameter	: 
# Purpose	: Handle get current value of download Graph CSV and Excel-XML
# Result	: Pass and Fail of compare result
# Comment	: 
# Download Setting:工具→網際網路選項→安全性→自訂等級->下載→自動提示下載檔案→啟用
# 	
def main 
    report_summary = ReportSummary.new(basename='report_csv_xml_result')
    report_summary.report_one_result(['CaseName', 'DownloadXML', 'DownloadCSV'])
    
    setting = ParseConfig.new('setting.ini')
    website_ip = setting.params['basic']['websit_ip']
    username = setting.params['basic']['username']
    password = setting.params['basic']['password']    
    
    report_root_name = setting.params['page']['report_root_name']
    include_rule = setting.params['page']['include_rule'].split(';')
    exclude_rule = setting.params['page']['exclude_rule'].split(';')
    
    pageControl = PageControl.new(report_root_name, website_ip, username, password)
    pageControl.set_filter_rules(exclude_rule=exclude_rule, include_rule=include_rule)
    
    expect_download_dir = File.join(report_summary.report_directory, 'Expect_Download_CSV_XML')
    FileUtils.mkdir_p(report_summary.current_download_dir) if !File.exist?(report_summary.current_download_dir)
	
    start_time = Time.now()
    while pageControl.goto_next_report_page
    
        report_case = create_report_case(pageControl.current_page_name)
        
        while report_case.goto_next_case()
            case_name = report_case.get_case_name()
            begin
                report_case.download_xml(report_summary.current_download_dir)
                result_xml = report_case.compare_xml(report_summary.current_download_dir, expect_download_dir)
                result_xml = result_xml ? 'Pass' : 'Failed'
            rescue Watir::Exception::UnknownObjectException
                result_xml = '-'
            rescue Watir::Wait::TimeoutError, RuntimeError => error
                result_xml = 'Failed'
                puts "#{case_name} #{error}"

            end
            
            begin
                report_case.download_csv(report_summary.current_download_dir)
                result_csv = report_case.compare_csv(report_summary.current_download_dir, expect_download_dir)
                result_csv = result_csv ? 'Pass' : 'Failed'
            rescue Watir::Exception::UnknownObjectException
                result_csv = '-'
            rescue Watir::Wait::TimeoutError, RuntimeError => error
                result_csv = 'Failed'
                puts "#{case_name} #{error}"
            end
            report_summary.report_one_result([case_name, result_xml, result_csv])
        end
        
        puts "\t\t\tCurrent Total Time #{Time.now() - start_time}"
        puts ""        
    end
    
    report_summary.export_report(format_type='csv_xml')
    
    puts "\t\t\tCurrent Total Time #{Time.now() - start_time}"
    puts ""
    pageControl.close
    report_summary.close
end

if __FILE__ == $0
    main()
end


