require 'nokogiri'
require 'xliffer/xliff/file'

module XLIFFer
  class XLIFF
    attr_reader :version, :files, :raw_xml
    def initialize(xliff = nil)
      text = case xliff
             when ::IO then xliff.read
             when ::String then xliff
             else fail ArgumentError, "Expects an IO or String"
             end

      parse(text)
    end

    private
    def parse(text)
      begin
        xml = Nokogiri::XML(text)
      rescue => e
        fail FormatError, "Not a XML file"
      end

      xml.remove_namespaces!
      root = xml.xpath('/xliff')
      raise FormatError, "Not a XLIFF file" unless root.any?

      @raw_xml = text
      @version = get_version(root)
      @files = parse_files(root)
    end

    def get_version(root)
      version = root.attr('version')
      version ? version.value : nil
    end

    def parse_files(root)
      root.xpath('//file').map{|f| File.new(f)}
    end

  end
end
