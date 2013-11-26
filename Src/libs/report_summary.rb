# Report all test case result to a file
# Format:
#    Router_Detail_P1		Pass
#    Router_Detail_P2		Pass
#    Router_Detail_PE4		Fail
class ReportSummary
    # basic_traffic_report/
    #   Current_Download_CSV_XML/
    #       Router_Detail_P1.csv
    #       Router_Detail_P2.csv
    #       ...    
    #   Expect_Download_CSV_XML/
    #       Router_Detail_P1_(expect).csv
    #       Router_Detail_P2_(expect).csv
    #       ...    
    #   report_diff_table/
    #       Router_Detail_P1.xls
    #       Router_Detail_P2.xls
    #       ...    
    #   expect_table/
    #       Router_Detail_P1.xls
    #       Router_Detail_P2.xls
    #       ...
    #   report_summary.xls
    #   report_csv_xml_result.xls
    attr_reader :report_directory, :report_diff_directory, :current_download_dir
    def initialize basename='report_summary', diff_dir='report_diff_table' 
        @report_list = Array.new
        @report_directory = '../basic_traffic_report'
        @report_diff_directory = diff_dir
        @current_download_dir = File.join(@report_directory, "Current_Download_CSV_XML")
        
        @output_basename = basename
        @counter_num = -1
        
        create_default_dir()
        set_counter_num()
    end
    
    # report_one_result(Array)
    # save a report reult of test case
    def report_one_result one_result
        @report_list.push(one_result)
        puts one_result.join("    ")
    end
    
    # export_report(format_type)
    # format_type = table or csv_xml
    # export all report to file
    def export_report format_type='table'
        puts '--'*30
        puts 'Report Summary'
        puts '--'*30
        
        @report_list.each { |test_case| puts test_case.join("\t\t")}
        
        
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet :name=> 'Report Summary'
        
        sheet1.column(0).width = 50 # column width of case_name 

        
        sheet1.row(0).push      
        
        @report_list.each_with_index do |test_case, idx|
            if format_type == 'table'
                export_table_format(test_case, sheet1, idx)
            else
                export_xml_csv_format(test_case, sheet1, idx)
            end
        end
        book.write(@output_pathname)
    end
    
    def close
    end
    
    private
        def export_table_format test_case, sheet1, idx
            format = Spreadsheet::Format.new :weight => :bold,  # for fomart of Hyberlink
                                           :color => :blue,
                                           :underline => :single
                                           
            case_name, result, time = test_case
            
            sheet1.row(idx).push case_name
            
            if result == 'Pass'
                sheet1.row(idx).push result
            else
                filename = File.join(@report_diff_directory, case_name.gsub(/[\\\/:\*\?<>|\"]/, '') + ".xls")
                sheet1.row(idx).set_format(1, format)
                sheet1.row(idx).push(Spreadsheet::Link.new url=filename, descreption = result)
            end
            
            sheet1.row(idx).push time        
        end
        
        def export_xml_csv_format test_case, sheet1, idx            
            sheet1.row(idx).concat test_case
        end
        
        def create_default_dir
            Dir.mkdir(@report_directory) if !File.exist?(@report_directory)
        end
        
        def set_counter_num
            path = File.join(@report_directory, @output_basename + "*.xls" )
            filelist = Dir.glob(path)
            
            pathname = ''
            begin
                @counter_num = @counter_num + 1
                if @counter_num == 0
                    filename = @output_basename + '.xls'
                else
                    filename = "#{@output_basename}_#{@counter_num}.xls"
                end
                
                pathname = File.join(@report_directory, filename)
            end while filelist.include?(pathname)
            
            @output_pathname = pathname
        end
end