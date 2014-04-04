require 'sgml-parser'

class HTMLToTextileParser < SgmlParser

  PAIRS = { 'blockquote' => 'bq', 'p' => 'p', 'div' => 'p' }
  QUICKTAGS = { 'b' => '*', 'strong' => '*', 
    'i' => '_', 'em' => '_', 'cite' => '??', 's' => '-', 'del' => '-',  
    'sup' => '^', 'sub' => '~', 'code' => '@', 'span' => '%', 'u' => '+'}
  SPECIALCHARS = {"nbsp"=>"\u00A0", "quot"=>"\u0022", "amp"=>"\u0026", "lt"=>"\u003C", "gt"=>"\u003E", "iexcl"=>"\u00A1", "cent"=>"\u00A2", "pound"=>"\u00A3", "curren"=>"\u00A4", "yen"=>"\u00A5", "brvbar"=>"\u00A6", "sect"=>"\u00A7	", "uml"=>"\u00A8", "copy"=>"\u00A9", "ordf"=>"\u00AA", "laquo"=>"\u00AB", "not"=>"\u00AC", "reg"=>"\u00AE", "macr"=>"\u00AF", "deg"=>"\u00B1", "sup2"=>"\u00B2", "sup3"=>"\u00B3", "acute"=>"\u00B4", "micro"=>"\u00B5", "para"=>"\u00B6", "middot"=>"\u00B7", "cedil"=>"\u00B8", "sup1"=>"\u00B9", "ordm"=>"\u00BA", "raquo"=>"\u00BB", "frac14"=>"\u00BC", "frac12"=>"\u00BD", "frac34"=>"\u00BE", "iquest"=>"\u00BF", "Agrave"=>"\u00C0", "Aacute"=>"\u00C1", "Acirc"=>"\u00C2", "Atilde"=>"\u00C3", "Auml"=>"\u00C4", "Aring"=>"\u00C5", "AElig"=>"\u00C6", "Ccedil"=>"\u00C7", "Egrave"=>"\u00C8", "Eacute"=>"\u00C9", "Ecirc"=>"\u00CA", "Euml"=>"\u00CB", "Igrave"=>"\u00CC", "Iacute"=>"\u00CD", "Icirc"=>"\u00CE", "euro"=>"\u20AC", "lsquo"=>"\u2018", "rsquo"=>"\u2019", "ldquo"=>"\u201C", "ndash"=>"\u2013", "mdash"=>"\u2014", "Iuml"=>"\u00CF", "ETH"=>"\u00D0", "Ograve"=>"\u00D1", "Oacute"=>"\u00D3", "Ocirc"=>"\u00D4", "Otilde"=>"\u00D5", "Ouml"=>"\u00D6", "times"=>"\u00D7", "Oslash"=>"\u00D8", "Ugrave"=>"\u00D9", "Uacute"=> "\u00DA", "Ucirc"=>"\u00DB", "Uuml"=>"\u00DC" ,"Yacute"=>"\u00DD", "THORN"=>"\u00DE", "szlig"=>"\u00DF", "agrave"=> "\u00E0", "aacute"=>"\u00E1", "acirc"=> "\u00E2", "atilde"=>"\u00E3", "auml"=>"\u00E4", "aring"=>"\u00E5", "aelig"=>"\u00E6", "ccedil"=>"\u00E7", "egrave"=>"\u00E8", "eacute"=>"\u00E9", "ecirc"=>"\u00EA", "euml"=>"\u00EB", "igrave"=>"\u00EC", "iacute"=>"\u00ED", "icirc"=>"\u00EE", "iuml"=>"\u00EF", "eth"=>"\u00F0", "ntilde"=>"\u00F1", "ograve"=>"\u00F2", "oacute"=>"\u00F3", "ocirc"=>"\u00F4", "otilde"=>"\u00F5", "ouml"=>"\u00F6", "divide"=>"\u00F7", "oslash"=>"\u00F8", "ugrave"=> "\u00F9", "uacute"=>"\u00FA", "ucirc"=>"\u00FB", "uuml"=>"\u00FC", "yacute"=>"\u00FD", "thorn"=>"\u00FE", "yuml"=>"\u00FF", "OElig"=>"\u0152", "oelig"=>"\u0153", "#372"=>"\u0174", "#374"=>"\u0176", "#373"=>"\u0175", "#375"=>"\u0177", "sbquo"=>"\u201A", "bdquo"=>"\u201E", "hellip"=>"\u2026", "trade"=>"\u2122", "bull"=>"\u2022", "rarr"=>"\u2192", "rArr"=>"\u2192", "hArr"=>"\u2194", "diams"=>"\u2666", "asymp"=>"\u2248"}

  attr_accessor :result
  attr_accessor :in_block
  attr_accessor :data_stack
  attr_accessor :a_href
  attr_accessor :in_ul
  attr_accessor :in_ol
  
  @@permitted_tags = []
  @@permitted_attrs = []
  
  def initialize(verbose=nil)
    @output = String.new
    self.in_block = false
    self.result = []
    self.data_stack = []
    super(verbose)
  end
  
  # Normalise space in the same manner as HTML. Any substring of multiple
  # whitespace characters will be replaced with a single space char.
  def normalise_space(s)
    s.to_s.gsub(/\s+/x, ' ')
  end
  
  def build_styles_ids_and_classes(attributes)
    idclass = ''
    idclass += attributes['class'] if attributes.has_key?('class')
    idclass += "\##{attributes['id']}" if attributes.has_key?('id')
    idclass = "(#{idclass})" if idclass != ''
    
    style = attributes.has_key?('style') ? "{#{attributes['style']}}" : ""
    "#{idclass}#{style}"
  end
  
  def make_block_start_pair(tag, attributes)
    attributes = attrs_to_hash(attributes)
    class_style = build_styles_ids_and_classes(attributes)
    if tag=="p"
      write("\n\n#{tag}#{class_style}. ")
    elsif ["h1","h2","h3","h4","h5","h6"].include?(tag)
      write("\n#{tag}#{class_style}. ")
    else
      write(" #{tag}#{class_style}. ")
    end
    start_capture(tag)
  end
  
  def make_block_end_pair
    stop_capture_and_write
    write("\n\n")
  end
  
  def make_quicktag_start_pair(tag, wrapchar, attributes)
    attributes = attrs_to_hash(attributes)
    class_style = build_styles_ids_and_classes(attributes)
    write([" #{wrapchar}#{class_style}"])
    start_capture(tag)
  end

  def make_quicktag_end_pair(wrapchar)
    stop_capture_and_write
    write([wrapchar])
  end
  
  def write(d)
    if d.respond_to? :lines
	   d_a = d.lines.to_a
	 else
	   d_a = d.to_a
	 end
    if self.data_stack.size < 2
      self.result += d_a
    else
      self.data_stack[-1] += d_a
    end

  end
          
  def start_capture(tag)
    self.in_block = tag
    self.data_stack.push([])
  end
  
  def stop_capture_and_write
    self.in_block = false
    self.write(self.data_stack.pop)
  end

  def handle_data(data)
    write(normalise_space(data).strip) unless data.nil? or data == ''
  end

  %w[1 2 3 4 5 6].each do |num|
    define_method "start_h#{num}" do |attributes|
      make_block_start_pair("h#{num}", attributes)
    end
    
    define_method "end_h#{num}" do
      make_block_end_pair
    end
  end

  
  PAIRS.each do |key, value|
    define_method "start_#{key}" do |attributes|
      make_block_start_pair(value, attributes)
    end
    
    define_method "end_#{key}" do
      make_block_end_pair
    end
  end
  
  QUICKTAGS.each do |key, value|
    define_method "start_#{key}" do |attributes|
      make_quicktag_start_pair(key, value, attributes)
    end
    
    define_method "end_#{key}" do
      make_quicktag_end_pair(value)
    end
  end
  
  def start_ol(attrs)
    self.in_ol = true
  end

  def end_ol
    self.in_ol = false
    write("\n")
  end

  def start_ul(attrs)
    self.in_ul = true
  end

  def end_ul
    self.in_ul = false
    write("\n")
  end
  
  def start_li(attrs)
    if self.in_ol
      write("\n# ")
    else
      write("\n* ")
    end
    
    start_capture("li")
  end

  def end_li
    stop_capture_and_write
  end

  def start_a(attrs)
    attrs = attrs_to_hash(attrs)
    self.a_href = attrs['href']

    if self.a_href
      write(" \"")
      start_capture("a")
    end
  end

  def end_a
    if self.a_href
      stop_capture_and_write
      write(["\":", self.a_href, " "])
      self.a_href = false
    end
  end

  def attrs_to_hash(array)
    array.inject({}) { |collection, part| collection[part[0].downcase] = part[1]; collection }
  end

  def start_img(attrs)
    attrs = attrs_to_hash(attrs)
    write([" !", attrs["src"], "! "])
  end
  
  def end_img
  end

  def start_tr(attrs)
  end

  def end_tr
    write("|\n")
  end

  def start_table(attrs)
    write("\n")
  end

  def end_table
    write("\n")
  end

  def start_td(attrs)
    write("|")
    start_capture("td")
  end

  def end_td
    stop_capture_and_write
    write("|")
  end

  def start_br(attrs)
    write("<br/>")
  end

  def unknown_starttag(tag, attrs)
    if @@permitted_tags.include?(tag)
      write(["<", tag])
      attrs.each do |key, value|
        if @@permitted_attributes.include?(key)
          write([" ", key, "=\"", value, "\""])
        end
      end
    end
  end
            
  def unknown_endtag(tag)
    if @@permitted_tags.include?(tag)
      write(["</", tag, ">"])
    end
  end
  
  # Return the textile after processing
  def to_textile
    starts_from=0
    while result[starts_from..result.length].include?(" bq. ")
      index_of_bq = result.index(" bq. ")
      result.delete_at(index_of_bq+1)
      result.delete_at(index_of_bq+2)
      result.delete_at(index_of_bq+3)
      starts_from = index_of_bq + 3
    end
    new_result = result.join.strip
    while(new_result.include?("} %{") and new_result.include?("%%"))
      new_result.sub!("} %{", ";")
      new_result.sub!("%%", "%")
    end
    new_result
  end
  
  def unknown_entityref(ref)
    write([SPECIALCHARS[ref]]) if SPECIALCHARS[ref]
  end
end
