require 'report_case/base/data_flow_case_base'

class BreakdownCase < DataFlowCaseBase
    def fetch_curr_table
        data_flow_table = @browserOperator.get_flow_table_matrix()
        current_table = FetchTable.parser_flow_table_matrix(data_flow_table, 'Last')
        
        current_table
    end
    
    def compare_table current_table, expect_table
        @compareTable.compare_matrix(current_table, expect_table)
    end
    
    def compare_xml_method current, expect
        @compareTable.compare_matrix(current, expect, merge_flow_type=false)
    end
    
    protected
        def collect_key
            case_panel = @browserOperator.get_case_panel
            #@report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_topn_value'))
            # @report_key_control.insert_key(SelectListKey.new(case_panel, 'topn_field_depth_select'))
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