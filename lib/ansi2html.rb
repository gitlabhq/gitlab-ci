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
    s = StringScanner.new(ansi.gsub("<", "&lt;"))
    while(!s.eos?)
      if s.scan(/\e\[(3[0-7]|90)m/) || s.scan(/\e\[1;(3[0-7])m/)
        if tag_open
          out << %{</span>}
        end
        out << %{<span class="#{COLOR[s[1]]}">}
        tag_open = true
      elsif s.scan(/\e\[1m/)
        # Just ignore bold style
      else
        if s.scan(/\e\[0m/)
          if tag_open
            out << %{</span>}
          end
          tag_open = false
        else
          out << s.scan(/./m)
        end
      end
    end
    if tag_open
      out << %{</span>}
    end
    out
  end
end
