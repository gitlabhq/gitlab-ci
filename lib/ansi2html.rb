# ANSI color library
module Ansi2html
  COLOR = {
    '1' => 'bold',
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
      if s.scan(/\e\[(3[0-7]|90|1)m/) || s.scan(/\[1;(3[0-7])m/)
        if tag_open
          out << %{</span>}
        end
        out << %{<span class="#{COLOR[s[1]]}">}
        tag_open = true
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
    out
  end
end
