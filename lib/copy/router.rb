module Copy
  class Router
    def initialize(path, views)
      @path  = determine_path(path)
      @views = views
    end
    
    def format
      @format ||= if @path.index('.')
        @path.split('.').last.to_sym
      else
        :html
      end
    end
    
    def template_file
      @template_file ||= if file = Dir.glob(File.join(@views, "#{path_with_format}*")).first
        file
      elsif index = Dir.glob(File.join(@views, path_without_format, "index.#{format}*")).first
        index
      end
    end
    
    def renderer
      @renderer ||= template_file.split('.').last.to_sym
    end
    
    def template
      @template ||= template_file.split('/').last.gsub(%r{.#{renderer}$}, '').to_sym
    end
    
    def success?
      template_file && renderer && template
    end
    
    private
      def determine_path(path)
        if path == '/'
          '/index'
        else
          path
        end
      end
      
      def path_without_format
        @path.split('.').first
      end

      def path_with_format
        "#{path_without_format}.#{format}"
      end
  end
end