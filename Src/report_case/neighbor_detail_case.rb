require 'report_case/base/data_flow_case_base'

class NeighborDetailCase < DataFlowCaseBase
    protected
        def collect_key
            case_panel = @browserOperator.get_case_panel
            @report_key_control.insert_key(SelectListKey.new(case_panel, 'rpt_ins_value'))
            super
        end
end