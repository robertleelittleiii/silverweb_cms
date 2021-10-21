#module ActionView
#  module Helpers
#    module SanitizeHelper
#      def sanitize(html, options = {})
#        self.class.white_list_sanitizer.sanitize(html.force_encoding('utf-8'), options).try(:html_safe)
#      end
#    end
#  end
#end