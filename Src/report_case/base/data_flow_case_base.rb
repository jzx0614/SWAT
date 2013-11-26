require 'report_case/base/report_case_base'

class DataFlowCaseBase < ReportCaseBase
    def fetch_curr_table
        data_flow_table = @browserOperator.get_data_flow_table()
        current_table = FetchTable.parser_data_flow_table(data_flow_table, 'Last')
        current_table
    end
    
    protected
        def collect_key
            super
            case_panel = @browserOperator.get_case_panel
            @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_counter_value'))
        end 
end