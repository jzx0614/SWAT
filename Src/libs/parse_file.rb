require 'csv'
require 'xmlsimple'

# Compare XML and CSV Result
module ParseFile
    def ParseFile.parser_csv_by_filename filename
        start_parse = false
        result = []
        CSV.foreach(filename) do |row|
            if start_parse == true
                result.push(row.drop(1))
            elsif row.length > 1
                start_parse = true                
            end
        end
        result.uniq!
    end
    
    def ParseFile.parser_xml_by_filename filename
        ignore_row_header = ['Report Name', 'Period', 'Time', 'Resource Name', 'TopN', 'Counter', 'Granularity']
        data = XmlSimple.xml_in(filename, { 'KeyAttr' => {'Worksheet' => 'ss:Name'},
                                            'GroupTags' => { 'Row' => 'Cell' },
                                            'ForceArray' => false})
        
        result = {}
        worksheet_list = data['Worksheet'].select{|key, value| key.include?('Last')}
        worksheet_list.each do |name, worksheet|
            result[name] = []
            row_list = worksheet['Table']['Row']
            row_list.each do |row|
                ary = []
                row['Cell'].each do |cell|
                    break if ignore_row_header.include?(cell['Data']['content'])
                    ary << cell['Data']['content']
                end
                result[name] << ary if !ary.empty?
            end
        end

        result
    end
    
    private
        def print_msg data, level
            return if level > 3
            def handle_value key, value, level
                if value.is_a?(String)
                    puts "    " * level << "%s -- %s" % [key, value]
                elsif value.is_a?(Hash)
                    puts "    " * level << "%s => {" % key
                    print_msg value, level+1
                    puts "    " * level << "}"
                elsif value.is_a?(Array)
                    puts "    " * level << "%s => [" % key
                    print_msg value, level+1
                    puts "    " * level << "]"
                end        
            end
            
            if data.is_a?(Hash)
                data.each{|key, value| handle_value(key, value, level)}
            elsif data.is_a?(Array)
                data.each{|value| handle_value(nil, value, level)}
            end
        end
end