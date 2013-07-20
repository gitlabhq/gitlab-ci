# ANSI color library
module Ansi2html
  COLOR = {
    '30' => 'black',
    '31' => 'red',
    '32' => 'green',
    '33' => 'yellow',
    '34' => 'blue',
    '35' => 'magenta',
    '36' => 'cyan',
    '37' => 'white',
    '90' => 'grey'
  }

  def self.convert(ansi)
    out = ""
    tag_open = false
    bold_tag_open = false
    s = StringScanner.new(ansi.gsub("<", "&lt;"))
    while(!s.eos?)
      if s.bol? && s.check(/.*\e\[2K/)
        s.skip(/.*\e\[2K/)
      end
      if s.scan(/\e\[(3[0-7]|90)m/) || s.scan(/\e\[1;(3[0-7])m/)
        if tag_open
          out << %{</span>}
        end
        out << %{<span class="#{COLOR[s[1]]}">}
        tag_open = true
      elsif s.scan(/\e\[1m/)
        out << %{<span style="font-weight:bold">}
        bold_tag_open = true
      elsif s.scan(/\e\[0m/) || s.scan(/\e\[39m/)
        if bold_tag_open
          out << %{</span>}
          bold_tag_open = false
        elsif tag_open
          out << %{</span>}
          tag_open = false
        end
      elsif s.scan(/\e\[\d{0,2}[GJKcghlmn]/)
        # Ignore other terminal control escape sequences
      else
        out << s.scan(/./m)
      end
    end
    if bold_tag_open
      out << %{</span>}
    end
    if tag_open
      out << %{</span>}
    end
    out
  end
end
