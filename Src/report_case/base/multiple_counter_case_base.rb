require 'report_case/base/report_case_base'

class MultipleCounterCaseBase < ReportCaseBase

    def fetch_curr_table
        counter_div = @browserOperator.get_counter_table()
        last_table = counter_div.table(:id, 'DetailCounterTable_Last')
        current_table = FetchTable.parser_counter_table(last_table, multiple=true)
        
        current_table
    end
end