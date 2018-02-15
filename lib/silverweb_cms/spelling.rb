module SilverwebCms
  module Spelling
    require 'net/https'
    require 'uri'
    require 'rexml/document'
    require 'open3'

    ASPELL_WORD_DATA_REGEX = Regexp.new(/\&\s\w+\s\d+\s\d+(.*)$/)
    ASPELL_PATH = "aspell"
  
    def check_spelling(spell_check_text, command, lang)
      json_response_values = Array.new
      json_hash = Hash.new()
      
      stdin, stdout, stderr, wait_thr = Open3.popen3("echo '#{spell_check_text}' | aspell -a -l #{lang}")
      spell_check_response = stdout.gets(nil)
      stdout.close
      
      error_string = stderr.gets(nil)
      stderr.close
      
      exit_code = wait_thr.value

      #spell_check_response = `echo "#{spell_check_text}" | aspelll -a -l #{lang}`
      if not error_string.blank? then
        json_hash[:error] = error_string
        return json_hash
      end
      
      # puts("Response: #{spell_check_response}")
      
      json_hash[:words] = {}

      if (spell_check_response != '') 
# not needed, was able to set the correct encoding at the system level for the spellchecker.
#        if ! spell_check_response.valid_encoding?
#          s = spell_check_response.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
#          s.gsub(/dr/i,'med')
#        end

        spelling_errors = spell_check_response.split(/\n& /).slice(1..-1)
        # puts(spelling_errors.inspect)
        # if (command == 'checkWords')
        if (command == 'spellcheck')
          i = 0
          
          while i < spelling_errors.length
            spelling_group = spelling_errors[i].split(": ")
            incorrct_word = spelling_group[0].split(" ").first
            correction_list = spelling_group[1]
            json_hash[:words][incorrct_word] = correction_list.split(", ")
            
            #            spelling_errors[i].strip!
            #              if (spelling_errors[i].to_s.index('&') == 0)
            #              match_data = spelling_errors[i + 1] 
            #              json_response_values << match_data 
            #            end
            i += 1 
          end
          json_response_values = json_hash
        elsif (command == 'getSuggestions')
          arr = spell_check_response.split(':')
          suggestion_string = arr[1]
          suggestions = suggestion_string.split(',') 
          for suggestion in suggestions
            suggestion.strip!
            json_response_values << suggestion 
          end
        end
      end 
      #  puts(json_response_values.inspect)
      return json_response_values
    end

    def check_spelling_old(spell_check_text, command, lang)
      xml_response_values = Array.new
      spell_check_text = spell_check_text.join(' ') if command == 'checkWords'
      spell_check_response = `echo "#{spell_check_text}" | #{ASPELL_PATH} -a -l #{lang}`
      if (spell_check_response != '')
        spelling_errors = spell_check_response.split("\n").slice(1..-1)
        if (command == 'checkWords')
          for error in spelling_errors
            error.strip!
            if (match_data = error.match(ASPELL_WORD_DATA_REGEX))
              arr = match_data[0].split(' ')
              xml_response_values << arr[1]
            end 
          end 
        elsif (command == 'getSuggestions') 
          for error in spelling_errors 
            error.strip! 
            if (match_data = error.match(ASPELL_WORD_DATA_REGEX)) 
              xml_response_values << error.split(',')[1..-1].collect(&:strip!)
              xml_response_values = xml_response_values.first
            end
          end 
        end 
      end 
      return xml_response_values
    end 
  end 
end