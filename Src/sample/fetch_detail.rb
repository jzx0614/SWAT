$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..") 

require "browser_operator"

def parser_counter_table counter_table
    result = Array.new
    
    # skip image cell
    counter_cell = counter_table.cells.select{ |cell| cell.class_name != 'div_all_types' }
    
    counter_cell.each_with_index do |cell, index_col|
        
        counter_divs = cell.divs.select{ |div| div.parent == cell} # filter div is leaf
        
        counter_divs.each_with_index do |div, index_row|
            result.push(Array.new) if index_col == 0 # initial row of result array when first row.
            result[index_row].push(div.text)
        end
    end
    result
end

if __FILE__ == $0
    browserOperator = BrowserOperator.instance
    browserOperator.login('192.168.80.206', 'admin')
    
    browser = browserOperator.browser
    browser.span(:id, 'lmenu_10102').click

    puts 'Goto detail page' 
    flow_type_div = browser.div(:id, 'div_counter_panel').when_present
    flow_type_div.tables.each do |flow_table|
        result = parser_counter_table(flow_table)
        puts flow_table.id << " " << result.to_s
        puts "---------\n"
    end
end