require "browser_operator"

# Handle to go to different report page. 
# Report page as follow:
#     Device->Router->Detail, 
#     Internet->Summary Report,
#     Sub-Network->TopN
class PageControl
    attr_reader:current_page_name
    def initialize report_root_name, website, username='admin', password='admin'
        @browserOperator = BrowserOperator.instance

        return if !autologin(website, username, password)

        @current_page_name = nil
        @include_rule = Array.new
        @exclude_rule = Array.new
        
        @time_out = 10
        @browserOperator.report_root_name = report_root_name
        get_all_page_id()
    end
        
    # autologin(website, username, password) > true or false
    # Auto use admin to login ATM6.
    # It will first use steal seesion. 
    # If it don't find user, it will use formal login method.
    # Parameter:
    #    website    you want to go to IP Address of ATM.
    #    username   login account
    #    password   login password
    def autologin website, username, password
        if !@browserOperator.login(website, username) and !@browserOperator.login(website, username, password)
            puts '[PageControl] Auto login fail' 
            close()
            return false
        end
        true
    end 
    
    def close
        @browserOperator.close
        @browserOperator = nil
    end
    
    # goto_next_report_page() > true or false
    # it will go next report page.
    # if browser don't next page, return false
    def goto_next_report_page
        page_id, @current_page_name = @page_id_list.shift
        return false if page_id.nil?
        
        begin
            report_panel = @browserOperator.get_report_panel # if change page, this element need re-get.
            
            if !match_filter?(@current_page_name)
                puts "[PageControl] Don't test " << @current_page_name << '. it was filtered.'
                return goto_next_report_page() 
            end
            
            page_element = report_panel.span(:id, page_id) # use page_id to re-parser page_element
            page_element.click
            
            puts '**' * 40
            puts '[PageControl] goto_next_report_page: ' << @current_page_name
            puts '**' * 40
            @browserOperator.wait_loading()
            return true
        rescue Watir::Exception::UnknownObjectException, Watir::Wait::TimeoutError  => error
            puts '[PageControl] goto_next_report_page have exception. ' << error
            return false
        end
    end
    
    # set_filter_rules( Array, Array ) > nil
    # it will filter by text of span.
    # if text of span in exclude, it will ignore when next page
    # if text of span in include, page of other isn't in include list will ignore when next page
    def set_filter_rules(exclude_rule=[], include_rules=[])
        @include_rule = include_rules
        @exclude_rule = exclude_rule
    end

    private
        # prepare page_id_list
        def get_all_page_id
            report_panel = @browserOperator.get_report_panel
            
            # save id of span
            # ex: [["lmenu_10010", "Report -> Bookmark"], 
            #      ["lmenu_10054", "Report -> Analyzer -> Route Analysis -> TopN"], 
            #      ["lmenu_10102", "Report -> Device -> Router -> Detail"],
            #      ...]
            @page_id_list = []
            
            # save current page stack 
            # ex: [["Report", "level0"], ["Device", "level1"], ["Router", "level2"]]
            current_page_stack = [] 
            
            report_panel.spans.each do |s|
                next if s.text == ''
                if s.id == ''  # the span have "+/-" icon
                    current_level_name = s.parent.class_name # level_name is "level1", "level2" ...

                    current_page_stack.keep_if do |page_name, level_name| # remove all page > current level_name 
                        level_name < current_level_name
                    end

                    current_page_stack << [s.text, current_level_name]
                    
                elsif s.id.include?('lmenu') # the span is leaf node
                    page_name = (current_page_stack.map{|page| page[0]} + [s.text]).join(' > ')
                    @page_id_list << [s.id, page_name]
                end
            end
        end
        
        def match_filter? page_name
            if !@include_rule.empty?
                match = false
                @include_rule.each do |rule|
                    if page_name.include?(rule)
                        match = true
                        break
                    end
                end
                
                return false if !match
            end
            
            @exclude_rule.each do |rule|
                return false if page_name.include?(rule)
            end
            
            true
        end
end