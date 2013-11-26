$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..") 

require "page_control"
require 'report_case/base/report_case_base'

def main 
    pageControl = PageControl.new('Report', '192.168.80.206')
    pageControl.set_filter_rules(exclude_rule=['Bookmark', 'Filter', 'Route Analysis', 'User-Agent Group', 'Server-farm'], include_rule=[])
    
    while pageControl.goto_next_report_page
    
        report_case = create_report_case(pageControl.current_page_name)
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
    end
    
    pageControl.close
end

if __FILE__ == $0
    main()
end


