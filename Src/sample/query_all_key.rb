$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..") 

require "page_control"

def test_key browser
    result = Array.new
    #test_keyname_list = %w(rpt_gp_value rpt_ins_value rpt_scope_ins_value rpt_scope_gp_value rpt_topn_value rpt_counter_value periodSelect topn_field_depth_select flowtb_chart_data_type)
    test_keyname_list = %w(rpt_ins_value rpt_topn_value rpt_counter_value topn_field_depth_select)
    browser.div(:id, 'TargetHead').when_present.click
    test_keyname_list.each do |id_name|
        element = browser.select_list(:id, id_name)
        r = ''
        if element.exist? and element.visible?
            r = element.options.length.to_s
        else
            r = 'x'
        end
        
        result.push(r)
    end
    
    result
end

def main

    pageControl = PageControl.new('Report', '192.168.80.206')
    pageControl.set_filter_rules(exclude_rule=['Bookmark', 'Filter', 'Route Analysis', 'User-Agent Group', 'Server-farm'], include_rule=[])
    
    browserOperator = BrowserOperator.instance
    
    result_hash = Hash.new
    while pageControl.goto_next_report_page
        obj_name, report_name = pageControl.current_page_name.split(" > ")[-2..-1]
        page_name = obj_name << "_" << report_name
        
        result = test_key(browserOperator.get_case_panel())
        result_hash[page_name] = result
    end
    puts ',' << test_keyname_list.join(',')
    result_hash.each do |key, value|
        puts ([key] + value).join(',')
    end
end


if __FILE__ == $0
    main()
end

