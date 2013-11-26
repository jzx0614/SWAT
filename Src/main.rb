$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'libs')

require 'parseconfig'
require 'page_control'
require 'report_summary'
require 'report_case/base/report_case_base'

alias org_puts puts
def puts output_string    
    $output_file << output_string << "\n"
    org_puts output_string
end

def main
    # load config file
    setting = ParseConfig.new('setting.ini')
    website_ip = setting.params['basic']['websit_ip']
    username = setting.params['basic']['username']
    password = setting.params['basic']['password']    
    
    report_root_name = setting.params['page']['report_root_name']
    include_rule = setting.params['page']['include_rule'].split(';')
    exclude_rule = setting.params['page']['exclude_rule'].split(';')
    
    report_summary = ReportSummary.new()
    
    pageControl = PageControl.new(report_root_name, website_ip, username, password)
    pageControl.set_filter_rules(exclude_rule=exclude_rule, include_rule=include_rule)
    
    start_time = Time.now()
    #change page loop
    while pageControl.goto_next_report_page
    
        report_case = create_report_case(pageControl.current_page_name)
        
        next if report_case.nil?
        
        export_diff_dir = File.join(report_summary.report_directory, report_summary.report_diff_directory)
        report_case.set_export_mode(export_diff_dir)
        
        process_dir = File.join(report_summary.report_directory, 'expect_table')
        
        start_case_time = Time.now()
        # change test case loop
        while report_case.goto_next_case()
            end_case_time = Time.now()
            current_table = expect_table = nil
            begin
                case_name = report_case.get_case_name()
                expect_table = report_case.fetch_expect_table(process_dir)
                current_table = report_case.fetch_curr_table()

                result = report_case.compare_table(current_table, expect_table)
            rescue Watir::Exception::UnknownObjectException, Watir::Wait::TimeoutError  => error
                result = false
                puts "#{case_name} #{error}"
            ensure
                report_case.export_diff_table_to_file(current_table, expect_table) if !result
                report_summary.report_one_result([case_name, result ? 'Pass' : 'Failed', end_case_time - start_case_time])
            end
            start_case_time = Time.now()
        end
        
        puts "\t\t\tCurrent Total Time #{Time.now() - start_time}"
        puts ""
    end

    report_summary.export_report()
    
    puts "\t\t\tCurrent Total Time #{Time.now() - start_time}"
    puts ""
    
    pageControl.close
    report_summary.close
    
end

if __FILE__ == $0
    $output_file = File.new('../main.log', 'w')
    main()
    $output_file.close()
end