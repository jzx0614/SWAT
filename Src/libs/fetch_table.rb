# Fetch expect file or current html table to 2-D array
module FetchTable

    # parser_counter_table(Watir::Table, Bool) > array
    # return a 2D array
    # Parser table of detail page (only detail page)
    # Parameter:
    #     counter_table  Watir::Table
    #     multiple      if true parse counter of 'Detail' Page, else other counter table
    def FetchTable.parser_counter_table(counter_table, multiple=false)
        result = Array.new
        drop_number = multiple ? 1 : 0
        # skip image cell
        counter_table.cells.drop(drop_number).each_with_index do |cell, index_col|
            # we only need the children of div, so drop div which isn't children of counter_cell
            counter_divs = cell.divs.select{ |div| div.parent == cell and div.class_name != 'div_counter_time'} 
            counter_divs.each_with_index do |div, index_row|
                result.push(Array.new) if index_col == 0 # initial row of result array when first row.
                result[index_row].push(div.text)
            end
        end
        result
    end
    
    # parser_data_flow_table(Watir::Table, String) > 2D array
    # Parser Data Flow table.
    # Parameter:
    #     data_flow_table  Watir::Table from the id = DataFlowTable
    #     flowtype         Average, Maximum, Last, Total or empty string

    def FetchTable.parser_data_flow_table(data_flow_table, flowtype='')
        result = Array.new
        
        # store index, it need match flowtype and flow_data_type
        index_list = Array.new
        header = data_flow_table[0]
        for cell_idx in (0...header.column_count)
            cell = header[cell_idx]
            if cell.id == '' or cell.id.include?(flowtype)
               index_list.push(cell_idx)
            end
        end
        
        data_flow_table.rows.each do |row|
            # get cell value from index_list
            result.push(row.to_a.values_at(*index_list))
        end
            
        result
    end
    
    # parser_flow_table_matrix(Watir::Table, String) > 2D array
    # Parser Dataflow table of Matrix or Breakdown .
    # Parameter:
    #     data_flow_table  Watir::Table from the id = DataFlowTable
    #     flowtype         Average, Maximum, Last, Total or empty string    
    def FetchTable.parser_flow_table_matrix(data_flow_table, flowtype='')
        result = Array.new

        result << data_flow_table.rows[0].to_a
        
        header_row = []
        data_flow_table.rows[1].each do |cell|
            begin
                idx = cell.div(:class, 'tbInnerColumnNum').text #fetch column num to remove it.
                idx << "\r\n"
            rescue Watir::Exception::UnknownObjectException
                idx = ''
            end
            
            header_row.push(cell.text.sub(idx, ''))
        end
        header_row << 'Comment'
        result.push(header_row)
        
        data_flow_table.rows.drop(2).each do |row|
            next if !row.id.include?(flowtype)

            row_list = row.to_a
            header_col = row[0]
            begin
                idx = header_col.div(:class, 'tbInnerRowNum').text #fetch row num to remove it.
            rescue Watir::Exception::UnknownObjectException
                idx = ''
            end
            row_list[0].sub!(idx, '')
            row_list.push(row.id)
            result.push(row_list)
        end
        
        result
    end
end
