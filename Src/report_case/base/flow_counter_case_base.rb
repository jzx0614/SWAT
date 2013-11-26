require 'report_case/base/report_case_base'

class FlowCounterCaseBase < ReportCaseBase
    def fetch_curr_table
        current_table = Array.new(2)
        
        counter_div = @browserOperator.get_counter_table()
        current_table[0] = FetchTable.parser_counter_table(counter_div.tables[0])
        
        data_flow_table = @browserOperator.get_data_flow_table()
        current_table[1] = FetchTable.parser_data_flow_table(data_flow_table, 'Last')
        
        current_table
    end
   
    def fetch_expect_table dir
        result = export_table.load_two_table(get_case_name(), dir)
    end  
    
    def export_table_to_file table
        export_table.export_two_table(get_case_name(), table)
    end
    
    def export_diff_table_to_file(current, expect)
        export_table.export_diff_two_table(get_case_name(), current, expect, @error_list)
    end
    protected
        def collect_key
            super
            case_panel = @browserOperator.get_case_panel
            @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_ins_value'))
            @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_topn_value'))
            @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_counter_value'))
        end
end