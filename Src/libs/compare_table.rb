# Compare Expect and Current Result
class CompareTable
    def initialize
        @error_list = {:current=>[], :expect=>[]}
    end
    
    def get_error
        return @error_list
    end
    
    def compare_table current, expect
        @array_idx_stack = []
        @error_list = {:current=>[], :expect=>[]}
        return compare_array current, expect

    end
    
    def compare_topn current, expect, have_index_column=true
        @error_list = {:current=>[], :expect=>[]}
        return false if !check_ary_lengh(current, expect)
        
        drop_number = have_index_column ? 1 : 0
        result = true
        
        key_idx = expect.first.index('Total %')
        expect_hash = Hash.new{|hash, key| hash[key] = Array.new}

        expect.each do |row|
            expect_hash[row[key_idx]] << row.drop(drop_number)
        end
        
        current.each_with_index do |row, row_idx|
            if !expect_hash[row[key_idx]].include?(row.drop(drop_number))
                result = false
                puts 'Error: TopN have different'
                puts expect_hash[row[key_idx]].to_s
                puts row.drop(drop_number).to_s
                @error_list[:current].push([row_idx])
                
                expect.each_with_index do |expect_row, expect_row_idx| # find expect table row idx
                    @error_list[:expect] << [expect_row_idx] if expect_row[key_idx] == row[key_idx]
                end

            end
        end
        
        result
    end

    def compare_matrix current, expect, merge_flow_type=true
        @error_list = {:current=>[], :expect=>[]}
        return false if !check_ary_lengh(current, expect)
        
        expect_hash = Hash.new {|hash, key| hash[key] = {}}
        
        @merge_flow_type = merge_flow_type
        
        def get_row_key row
            row_key = @merge_flow_type ? [row.first, row.last].join(" ") : row.first
        end
        
        expect.drop(2).each do |row|
            row_key = get_row_key(row)
            for col_idx in 1...row.length-1
                cell = row[col_idx]
                col_key = expect[1][col_idx]
                expect_hash[row_key][col_key] = cell
            end
        end
        
        def find_expect_index_by_key table, row_key, col_key
            table.each_with_index do |row, row_idx| # find expect table row idx
                current_row_key = get_row_key(row)
                next if current_row_key != row_key
                
                col_idx = table[1].index col_key
                @error_list[:expect] << [row_idx, col_idx] if !col_idx.nil?
            end            
        end
        
        result = true
        current.drop(2).each_with_index do |row, row_idx|
            row_key = get_row_key(row)
            for col_idx in 1...row.length-1 
                cell = row[col_idx]
                col_key = current[1][col_idx]
                next if expect_hash[row_key][col_key] == cell
                result = false
                puts "Error key:" << [row_key, col_key].to_s
                puts [expect_hash[row_key][col_key], cell].to_s
                
                @error_list[:current].push([row_idx+2, col_idx])
                
                find_expect_index_by_key(expect, row_key, col_key)
            end        
        end

        result
    end
    private
        # compare_array(Array, Array) > true or false
        # recurive to parser Array
        # until get string compare
        def compare_array(current, expect)
            if current.class != Array
                result = (current == expect)
                if !result
                    puts 'Error: ' << @array_idx_stack.to_s << '-'*10
                    puts [current, expect].to_s
                    @error_list[:current].push(@array_idx_stack.dup)
                    @error_list[:expect].push(@array_idx_stack.dup)
                end
                return result
            end
           
            return false if !check_ary_lengh(current, expect)
            
            result = true
            for idx in (0...current.length)
                @array_idx_stack.push(idx)
                if !compare_array(current[idx], expect[idx])
                    result = false
                    # return false
                end
                @array_idx_stack.pop
            end
            
            return result
        end
        
        def check_ary_lengh(current, expect)
            return true if current.length == expect.length
            
            puts '[CompareTable] length ' << [current.length, expect.length].to_s
            @error_list[:expect].push("[Error] Array length don't match.")
            @error_list[:expect].push('current: %d expect: %d' % [current.length, expect.length])
            return false 
        end
end