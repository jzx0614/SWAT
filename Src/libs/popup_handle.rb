# encoding: big5
require 'rautomation'
require 'win32ole'
module PopupHandle
    # deal_download_dialog(String)
    # file_name：文件名，如：test.txt
    #
    # Ex: PopupHandle.deal_download_dialog("test")
    #
    def PopupHandle.deal_download_dialog(file_path)
        puts '[PopupHandle] deal_download_dialog'
        dialog_title = ['檔案下載','檔案下載 - 安全性警告','文件下載 - 安全警告','文件下載','File Download']
        find_title_string = dialog_title.map{|title| "(%s)" % title}.join('|').force_encoding("ASCII-8BIT")
        
        win = PopupHandle.find_dialog_window(:class => '#32770', :title => /#{find_title_string}/)
        win.send_keys('{ALT}S')
        
        PopupHandle.deal_path_dialog(file_path)       
    end
    # deal_path_dialog(String)
    # file_name：文件名，如：test.txt
    #
    # Ex: PopupHandle.deal_path_dialog("test")
    #
    def PopupHandle.deal_path_dialog(file_path)
        puts '[PopupHandle] deal_path_dialog'
        dialog_title = ['另存新檔', '另存為']
        find_title_string = dialog_title.map{|title| "(%s)" % title}.join('|').force_encoding("ASCII-8BIT")

        win = PopupHandle.find_dialog_window(:class => '#32770', :title=> /#{find_title_string}/)
        filename_textfield = win.text_field(:class => "Edit")
        
        File.delete(file_path) if File.exist?(file_path)
		file_path = File.join(Dir.pwd, file_path).gsub('/', "\\")
        filename_textfield.set file_path
        win.send_keys('{ENTER}')
		sleep 2
		WIN32OLE.new("WScript.Shell").SendKeys('%{F4}')
    end
		
		   
    protected
        def PopupHandle.find_dialog_window(*args)
            time_out = 10
            
            begin
                Timeout::timeout(time_out) do
                    sleep(0.5) until (win = RAutomation::Window.new(*args)).exist?
                    return win
                end
            rescue Timeout::Error
                puts "[PopupHandle] Find Window TimeOut %s" % args
                raise
            end
            
        end
end