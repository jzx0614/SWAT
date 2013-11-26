# encoding: utf-8
$LOAD_PATH.unshift File.dirname(__FILE__) 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'libs')

require 'fileutils'
require 'parseconfig'
require 'page_control'
require 'report_case/base/report_case_base'

# 
# Function  : process_expect_download_xml_csv_main.rb
# Parameter	: 
# Purpose	: Handle get expect value of download Graph CSV and Excel-XML
# Result	: expect value of CSV and XML
# Comment	: 
# Download Setting:工具→網際網路選項→安全性→自訂等級->下載→自動提示下載檔案→啟用
# 	
def main     
    setting = ParseConfig.new('setting.ini')
    website_ip = setting.params['basic']['websit_ip']
    username = setting.params['basic']['username']
    password = setting.params['basic']['password']    
    
    report_root_name = setting.params['page']['report_root_name']
    include_rule = setting.params['page']['include_rule'].split(';')
    exclude_rule = setting.params['page']['exclude_rule'].split(';')
    
    pageControl = PageControl.new(report_root_name, website_ip, username, password)
    pageControl.set_filter_rules(exclude_rule=exclude_rule, include_rule=include_rule)    
    
    start_time = Time.now()
    while pageControl.goto_next_report_page
    
        report_case = create_report_case(pageControl.current_page_name)
		download_dir = File.join('..', 'basic_traffic_report', 'Expect_Download_CSV_XML')
		FileUtils.mkdir_p(download_dir) if !File.exist?(download_dir)
	
        while report_case.goto_next_case()
            case_name = report_case.get_case_name()
            begin
                report_case.download_xml(download_dir, expect=true)
            rescue Watir::Wait::TimeoutError, Watir::Exception::UnknownObjectException, RuntimeError => error
                puts "#{case_name} #{error}"               
            end
            begin
            		 report_case.download_csv(download_dir, expect=true)
            rescue Watir::Wait::TimeoutError, Watir::Exception::UnknownObjectException, RuntimeError => error
                puts "#{case_name} #{error}"
            end
        end
        
        puts "\t\t\tCurrent Total Time #{Time.now() - start_time}"
        puts ""        
    end
    
    
    puts "\t\t\tCurrent Total Time #{Time.now() - start_time}"
    puts ""
    pageControl.close
end

if __FILE__ == $0
    main()
end


