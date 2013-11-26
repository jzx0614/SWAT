require 'report_case/base/flow_counter_case_base'

class TopNCase < FlowCounterCaseBase
    def compare_table current_table, expect_table
        @error_list = []
        result1 = @compareTable.compare_table(current_table[0], expect_table[0])
        @error_list << @compareTable.get_error()
        
        result2 = @compareTable.compare_topn(current_table[1], expect_table[1])
        @error_list << @compareTable.get_error()
        return (result1 and result2)
    end
    
    def compare_xml_method current, expect
        @compareTable.compare_topn(current, expect, have_index_column=false)
    end
    
    protected
        def collect_key
            case_panel = @browserOperator.get_case_panel
            @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_ins_value'))
            
            topn_key = SelectListKey.new(case_panel, 'rpt_topn_value')
            counter_key = SelectListKey.new(case_panel, 'rpt_counter_value')
            if @obj_name == 'Server-farm'
                @report_key_control.insert_relation_keys([topn_key, counter_key])
            else
                @report_key_control.insert_key(topn_key)
                @report_key_control.insert_key(counter_key)
            end
        end    
end