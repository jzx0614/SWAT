require "browser_operator"
# Handle to go to different testCase (table)
# "Key" example:
#    Period: Daily, Weekly, Monthly, Yearly
#    Counter: Max, Avg, Last, Total
class ReportKeyContrl
    def initialize 
        @element_list = Array.new
        @case_list = Array.new
        
        @browserOperator = BrowserOperator.instance
        @case_panel = @browserOperator.get_case_panel()
        
    end

    # get all the value of key
    def get_key_list
        key_list = Array.new
        @element_list.each do |element|
            value = element.get_current_value()
            key_list += value if !value.nil?
        end
        #puts '[ReportKeyContrl] get_key_list: ' << key_list.to_s
        key_list
    end
    
    # insert_key(Object key_object)
    # Parameter:
    #   key_object    a Object, it will inhert ElementKeyBase
    # Ex:
    #   @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_ins_value'))
    #   @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_topn_value'))
    #   @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_counter_value', ['bps', 'pps']))
    #   @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_ins_value'))
    #   @report_key_control.insert_key(SelectListKey.new(case_panel, 'topn_field_depth_select'))
    def insert_key(key_object)

        # only 1 key. insert values length 
        # 2+ key, insert values length > 1
        if !key_object.element_exist? or 
           (@element_list.length >= 1 and key_object.get_values().length <= 1) 
            puts "[ReportKeyContrl] insert_key: #{key_object.name} be ignored."
            return
        end
        
        if @element_list.length == 1
            # check first key length when insert second key
            # if length == 1, remove first key
            first_values = @element_list.first.get_values()
            if first_values.length == 1
                @element_list.pop
                clear_case_list()
                puts "[ReportKeyContrl] insert_key: #{first_values.to_s} be ignored."
            end         
        end
        
        puts '[ReportKeyContrl] insert_key: ' << key_object.name << "\t" << key_object.get_values.to_s
        
        @element_list.push(key_object)
        
        values = @element_list.last.get_values()
        product_case_list(values)

    end
    
    # insert_relation_keys(key_list)
    # Parameter:
    #   key_list    Array of Object
    # Ex:
    # @report_key_control.insert_relation_keys([SelectListKey.new(case_panel, 'rpt_topn_value'), SelectListKey.new(case_panel, 'rpt_counter_value')])
    #    
    # it will insert some key, then walker all case from browser.
    def insert_relation_keys(keys_list)
        def get_produce_value key_list, idx, values
            if idx == key_list.length
                values << key_list.inject([]) do |value_list, element|
                    value = element.get_current_value
                    value_list += value if !value.nil?
                end
                return
            end
            
            key_list[idx].get_values().inject([]) do |value_list, value|
                key_list[idx].set_text(value)
                get_produce_value(key_list, idx+1, values)
            end
        end
        values = []
        get_produce_value(keys_list, 0, values)
        @element_list.concat(keys_list)
        product_case_list(values)
    end
    
    #go to next test case
    def goto_next_case()
        case_values = @case_list.shift
        return false if case_values.nil?
        
        case_values.flatten!
        begin
            case_values.each_with_index do |value, idx|
                @element_list[idx].set_text(value)
            end
            
            @case_panel.button(:value, 'Submit').click
            puts '[ReportKeyContrl] goto_next_case ' << case_values.to_s
            
            @browserOperator.wait_loading()
            return true
        rescue Watir::Exception::UnknownObjectException, Watir::Wait::TimeoutError  => error
            puts "[ReportKeyContrl] goto_next_case have exception. #{error}"
            return false
        end        
    end

    private
        def product_case_list(value_list)
            if @case_list.empty?
                @case_list = value_list.product()
            else
                @case_list = @case_list.product(value_list)
            end
            puts "[ReportKeyContrl] product_case_list #{@case_list.length}"
        end
        
        def clear_case_list()
            @case_list = []
        end
end

class ElementKeyBase
    attr_reader :name, :element_object
    def initialize case_panel, name, rule=[]
        @case_panel = case_panel
        @name = name
        @rule = rule
        @element_object = get_element_object()
    end
    
    def get_element_object
    end
    
    def element_exist?
        @element_object.exist?
    end
    
    def set_text value
    end
    
    def get_values
    end
    
    def get_current_value
    end
end

class SelectListKey < ElementKeyBase
    def get_element_object
        @case_panel.select_list(:id, @name)
    end

    def set_text value
        return if get_current_value() == value
        @element_object.set(value)    
    end
    
    def get_values
        result = @element_object.options
        result.keep_if{|value| @rule.include?(value)} if !@rule.empty?
        result
    end
    
    def get_current_value
        result = @element_object.selected_options    
    end
end