require 'report_case/base/flow_counter_case_base'

class MatrixCase < FlowCounterCaseBase
    def fetch_curr_table
        current_table = Array.new(2)
        
        counter_div = @browserOperator.get_counter_table()
        current_table[0] = FetchTable.parser_counter_table(counter_div.tables[0])
        
        data_flow_table = @browserOperator.get_flow_table_matrix()
        current_table[1] = FetchTable.parser_flow_table_matrix(data_flow_table, 'Last')
        
        current_table
    end
    
    def compare_table current_table, expect_table
        @error_list = []
        result1 = @compareTable.compare_table(current_table[0], expect_table[0])
        @error_list << @compareTable.get_error()
        result2 = @compareTable.compare_matrix(current_table[1], expect_table[1])
        @error_list << @compareTable.get_error()
        return (result1 and result2)
    end
    
    def compare_xml_method current, expect
        @compareTable.compare_matrix(current, expect, merge_flow_type=false)
    end
        
end