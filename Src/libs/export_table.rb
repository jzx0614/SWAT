require 'spreadsheet'

# Export a test case to Excel
class ExportTable
    def initialize dir='basic_traffic_report'
        @report_directory = dir
        @titile_format = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 18
        @error_format = Spreadsheet::Format.new :color => :red, :weight => :bold
        @error_format1 = Spreadsheet::Format.new :pattern_fg_color => :red, :pattern => 1
        @warning_format = Spreadsheet::Format.new :color => :red, :weight => :bold, :size => 18
        
        create_default_dir()
    end

    # export_diff_one_table()
    # export test case fail table
    # it will export current test table and excpect table to file
    # it only support one counter table or one dataflow table
    def export_diff_one_table(case_name, current, expect, error_list)
        pathname = get_path_name(case_name, @report_directory)
        
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet :name=> case_name
        
        sheet1.row(0).push "Current Test Table"
        sheet1.row(0).default_format = @titile_format

        curr_row_idx = sheet1.last_row_index + 1 
        export_table_to_excel(curr_row_idx, sheet1, current)
        
        idx = sheet1.last_row_index + 1        
        sheet1.row(idx).push "Expect Table"
        sheet1.row(idx).default_format = @titile_format
       
        expect_row_idx = sheet1.last_row_index + 1
        export_table_to_excel(expect_row_idx, sheet1, expect)
        
        handle_error_list(curr_row_idx, expect_row_idx, sheet1, error_list)
        book.write(pathname)
    end

    # export_diff_two_table()
    # export test case fail table
    # it will export current test table and excpect table to file    
    # it support counter table and dataflow table.
    # Ex. Matrix and TopN case
    def export_diff_two_table(case_name, current, expect, error_list)
        pathname = get_path_name(case_name, @report_directory)
        
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet :name=> case_name
        
        sheet1.row(0).push "Current Test Table"
        sheet1.row(0).default_format = @titile_format
        
        curr_row_idx = sheet1.last_row_index + 1 
        export_two_table_to_excel(curr_row_idx, sheet1, current)

        idx = sheet1.last_row_index + 1
        sheet1.row(idx).push "Expect Table"
        sheet1.row(idx).default_format = @titile_format
       
        expect_row_idx = sheet1.last_row_index + 1 
        export_two_table_to_excel(expect_row_idx, sheet1, expect)
        
        if !error_list.nil?
            handle_error_list(curr_row_idx, expect_row_idx, sheet1, error_list[0])
            handle_error_list(curr_row_idx + current[0].length + 1, expect_row_idx + expect[0].length + 1, sheet1, error_list[1])
        end
        book.write(pathname)
    end
    
    def export_one_table(case_name, table)
        # puts '[ExportTable] export_one_table_to_excel -- ' << case_name
        pathname = get_path_name(case_name, @report_directory)

        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet :name=> case_name
        
        export_table_to_excel(0, sheet1, table)

        book.write(pathname)
    end    
    
    def export_two_table(case_name, table)
        # puts '[ExportTable] export_one_table_to_excel -- ' << case_name
        counter_table = table[0]
        dataflow_table = table[1]

        pathname = get_path_name(case_name, @report_directory)

        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet :name=> case_name
        
        export_two_table_to_excel 0, sheet1, table
        
        book.write(pathname)
    end     
  
    def load_one_table(case_name, dir)
        result = []
        pathname = get_path_name(case_name, dir)
        if !File.exist?(pathname)
            puts "[ExportTable] load_one_table: File isn't exist. #{pathname}"
            return result 
        end
        
        book = Spreadsheet.open pathname
        sheet = book.worksheet 0
        sheet.each do |row|
            result << row.to_a.map do |cell|
                cell.nil? ? "" : cell
            end
        end

        result
    end

    def load_two_table(case_name, dir)
        result = Array.new(2){[]}
        pathname = get_path_name(case_name, dir)
        
        if !File.exist?(pathname)
            puts "[ExportTable] load_one_table: File isn't exist. #{pathname}"
            return result 
        end

        book = Spreadsheet.open pathname
        sheet = book.worksheet 0
        
        out_ary = result[0]
        
        sheet.each do |row|
            if row.empty?
                out_ary = result[1] 
                next
            end
            out_ary << row.to_a.map do |cell|
                cell.nil? ? "" : cell
            end
        end

        result
    end
    
    private
        def export_table_to_excel offset_row_idx, sheet, table
            return if table.nil?
            table.each_with_index do |row, row_idx|
                sheet.row(offset_row_idx + row_idx).concat row
            end        
        end
        
        def export_two_table_to_excel offset_row_idx, sheet, table
            return if table.nil?
            
            counter_table = table[0]
            dataflow_table = table[1]
            
            export_table_to_excel(offset_row_idx, sheet, counter_table)

            new_row_idx = sheet.last_row_index + 2
            export_table_to_excel(new_row_idx, sheet, dataflow_table)
        end
        
        def handle_error_list(curr_idx, expect_idx, sheet, error_list)
            offset_idx_list = {:current=>curr_idx, :expect=>expect_idx}
            error_list.each do |key, error_table|
                error_table.each do |error|
                    if error.is_a?(Array)
                        offset_idx = offset_idx_list[key]
                        color_cell_by_idx(offset_idx, sheet, error)
                    elsif error.is_a?(String)
                        puts '[handle_error_list] %s ' % error
                        row_idx = sheet.last_row_index + 1
                        sheet.row(row_idx).push(error)
                        sheet.row(row_idx).set_format(0, @warning_format)
                    end
                end
            end
        end
        
        def color_cell_by_idx(offset_row_idx, sheet, idx_list)
            if idx_list.length == 2
                row, col = idx_list
                sheet.row(offset_row_idx+row).set_format(col, @error_format)
            else
                sheet.row(offset_row_idx+idx_list[0]).default_format =  @error_format1
            end
        end
        
        def create_default_dir
            return if File.exist?(@report_directory)
            require 'fileutils'
            FileUtils.mkdir_p(@report_directory)
        end
        
        def get_path_name case_name, dir
            File.join(dir, fix_casename_to_filename(case_name) + '.xls')
        end
        
        def fix_casename_to_filename case_name
            filename = case_name.gsub(/[\\\/:\*\?<>|\"]/, '')
        end
end
