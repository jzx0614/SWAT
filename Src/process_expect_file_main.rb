$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'libs')

require 'parseconfig'
require 'page_control'
require 'report_case/base/report_case_base'

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
        page_start_time = Time.now
        report_case = create_report_case(pageControl.current_page_name)
        next if report_case.nil?
        report_case.set_export_mode(File.join('../basic_traffic_report', 'expect_table'))
        
        while report_case.goto_next_case()
            begin
                case_name = report_case.get_case_name()
                current_table = report_case.fetch_curr_table()
                
                report_case.export_table_to_file(current_table)
                
            rescue Watir::Exception::UnknownObjectException, Watir::Wait::TimeoutError  => error
                result = false
                puts "#{case_name} #{error}"
            end
        end
        page_end_time = Time.now()

        puts "\t\t\t#{case_name} Cost Time: #{page_end_time - page_start_time}"
        puts "\t\t\tCurrent Total Time #{page_end_time - start_time}"
        puts ""
    end
    
    pageControl.close
end

if __FILE__ == $0
    main()
end