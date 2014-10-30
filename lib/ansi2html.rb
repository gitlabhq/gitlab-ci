# ANSI color library
#
# Implementation per http://en.wikipedia.org/wiki/ANSI_escape_code
module Ansi2html
  # keys represent the trailing digit in color changing command (30-37, 40-47, 90-97. 100-107)
  COLOR = {
    0 => 'black', # not that this is gray in the intense color table
    1 => 'red',
    2 => 'green',
    3 => 'yellow',
    4 => 'blue',
    5 => 'magenta',
    6 => 'cyan',
    7 => 'white', # not that this is gray in the dark (aka default) color table
  }

  STYLE_SWITCHES = {
    :bold      => 0x01,
    :italic    => 0x02,
    :underline => 0x04,
    :conceal   => 0x08,
    :cross     => 0x10,
  }

  def self.convert(ansi)
    Converter.new().convert(ansi)
  end

  class Converter
    def on_0(s) reset()                            end
    def on_1(s) enable(STYLE_SWITCHES[:bold])      end
    def on_3(s) enable(STYLE_SWITCHES[:italic])    end
    def on_4(s) enable(STYLE_SWITCHES[:underline]) end
    def on_8(s) enable(STYLE_SWITCHES[:conceal])   end
    def on_9(s) enable(STYLE_SWITCHES[:cross])     end

    def on_21(s) disable(STYLE_SWITCHES[:bold])      end
    def on_22(s) disable(STYLE_SWITCHES[:bold])      end
    def on_23(s) disable(STYLE_SWITCHES[:italic])    end
    def on_24(s) disable(STYLE_SWITCHES[:underline]) end
    def on_28(s) disable(STYLE_SWITCHES[:conceal])   end
    def on_29(s) disable(STYLE_SWITCHES[:cross])     end

    def on_30(s) set_fg_color(0) end
    def on_31(s) set_fg_color(1) end
    def on_32(s) set_fg_color(2) end
    def on_33(s) set_fg_color(3) end
    def on_34(s) set_fg_color(4) end
    def on_35(s) set_fg_color(5) end
    def on_36(s) set_fg_color(6) end
    def on_37(s) set_fg_color(7) end
    def on_38(s) set_fg_color_256(s) end
    def on_39(s) set_fg_color(9) end

    def on_40(s) set_bg_color(0) end
    def on_41(s) set_bg_color(1) end
    def on_42(s) set_bg_color(2) end
    def on_43(s) set_bg_color(3) end
    def on_44(s) set_bg_color(4) end
    def on_45(s) set_bg_color(5) end
    def on_46(s) set_bg_color(6) end
    def on_47(s) set_bg_color(7) end
    def on_48(s) set_bg_color_256(s) end
    def on_49(s) set_bg_color(9) end

    def on_90(s) set_fg_color(0, 'l') end
    def on_91(s) set_fg_color(1, 'l') end
    def on_92(s) set_fg_color(2, 'l') end
    def on_93(s) set_fg_color(3, 'l') end
    def on_94(s) set_fg_color(4, 'l') end
    def on_95(s) set_fg_color(5, 'l') end
    def on_96(s) set_fg_color(6, 'l') end
    def on_97(s) set_fg_color(7, 'l') end
    def on_99(s) set_fg_color(9, 'l') end

    def on_100(s) set_bg_color(0, 'l') end
    def on_101(s) set_bg_color(1, 'l') end
    def on_102(s) set_bg_color(2, 'l') end
    def on_103(s) set_bg_color(3, 'l') end
    def on_104(s) set_bg_color(4, 'l') end
    def on_105(s) set_bg_color(5, 'l') end
    def on_106(s) set_bg_color(6, 'l') end
    def on_107(s) set_bg_color(7, 'l') end
    def on_109(s) set_bg_color(9, 'l') end

    def convert(ansi)
      @out = ""
      @line = ""
      @line_clear = false
      @line_duration = nil
      @line_fold = nil
      @n_open_tags = 0
      @n_open_folds = []
      @n_lines = 0
      reset()

      s = StringScanner.new(ansi)
      while(!s.eos?)
        if s.scan(/\e([@-_])(.*?)([@-~])/)
          handle_sequence(s)
        elsif s.scan(/\r?\n/)
          finish_line()
          begin_line()
        elsif s.scan(/\r/)
          @line_clear = true
        elsif s.scan(/</)
          append_text("&lt;")
        elsif s.scan(/travis_fold:start:([^\r]*)\r/)
          open_new_fold(s[1])
        elsif s.scan(/travis_fold:end:([^\r]*)\r/)
          close_open_fold()
        elsif s.scan(/travis_time:start:([^\r]*)\r/)
          unless @line.empty?
            finish_line()
            begin_line()
          end
          @line_duration = "id-time-#{s[1]}"
        elsif s.scan(/travis_time:(end|finish):([^:]*):start=([^,]*),finish=([^,]*),duration=([^\r]*)\r/)
          line_duration = s[5].to_i / 1000.0 / 1000.0 / 1000.0
          line_duration = beautify_duration(line_duration)
          @out << "<script>var duration=document.getElementById('id-time-#{s[2]}'); if(duration) { duration.innerHTML = duration.title = '#{line_duration}'; }</script>"
          @line_duration = nil
        else
          append_text(s.scan(/./m))
        end
      end

      close_open_folds()
      @out
    end

    def handle_sequence(s)
      indicator = s[1]
      commands = s[2].split ';'
      terminator = s[3]

      # We are only interested in color and text style changes - triggered by
      # sequences starting with '\e[' and ending with 'm'. Any other control
      # sequence gets stripped (including stuff like "delete last line")
      return unless indicator == '[' and terminator == 'm'

      close_open_tags()

      if commands.empty?()
        reset()
        return
      end

      evaluate_command_stack(commands)
      append_style()
    end

    def begin_line()
      @line = ""
      @line_duration = nil
      @n_open_tags = 0
      append_style()
    end

    def finish_line()
      @line_clear = false
      close_open_tags()
      @n_lines += 1
      if @line_fold
        @out << %{<p onclick="javascript:Fold_Section('#{@line_fold}')">}
        @line_fold = nil
      else
        @out << %{<p>}
      end
      @out << %{<a></a>}
      @out << %{<span id="#{@line_duration}" class="duration" title="duration">duration</span>} unless @line_duration.nil?
      @out << %{<span id="id-1-#{@n_lines}">#{@line}</span>}
      @out << %{</p>}
    end

    def append_text(text)
      if @line_clear
        @line = ""
        @line_clear = false
      end
      @line << text
    end

    def append_style()
      css_classes = []

      unless @fg_color.nil?
        fg_color = @fg_color
        # Most terminals show bold colored text in the light color variant
        # Let's mimic that here
        if @style_mask & STYLE_SWITCHES[:bold] != 0
          fg_color.sub!(/fg-(\w{2,}+)/, 'fg-l-\1')
        end
        css_classes << fg_color
      end
      css_classes << @bg_color unless @bg_color.nil?

      STYLE_SWITCHES.each do |css_class, flag|
        css_classes << "term-#{css_class}" if @style_mask & flag != 0
      end

      open_new_tag(css_classes) if css_classes.length > 0
    end

    def evaluate_command_stack(stack)
      return unless command = stack.shift()

      if self.respond_to?("on_#{command}", true)
        self.send("on_#{command}", stack)
      end

      evaluate_command_stack(stack)
    end

    def open_new_tag(css_classes)
      append_text(%{<span class="#{css_classes.join(' ')}">})
      @n_open_tags += 1
    end

    def close_open_tags
      while @n_open_tags > 0
        append_text(%{</span>})
        @n_open_tags -= 1
      end
    end

    def open_new_fold(fold_name)
      finish_line
      @line_fold = "fold-start-" + ('a'..'z').to_a.shuffle.first(8).join
      @out << %{<div id="#{@line_fold}" class="fold-start fold">}
      @out << %{<span class="fold-name">#{fold_name}</span>}
      @n_open_folds << @line_fold
      begin_line
    end

    def close_open_fold
      unless @n_open_folds.empty?
        finish_line
        @out << "</div>"
        @n_open_folds.pop
        begin_line
      end
    end

    def close_open_folds
      finish_line unless @line.empty?

      # close section and make it open
      while @n_open_folds.size > 0
        fold_name = @n_open_folds.pop
        @out << "</div>"
        @out << "<script>var fold = document.getElementById('#{fold_name}'); if(fold) { fold.classList.add(\"open\"); }</script>"
      end
    end

    def reset
      @fg_color = nil
      @bg_color = nil
      @style_mask = 0
    end

    def enable(flag)
      @style_mask |= flag
    end

    def disable(flag)
      @style_mask &= ~flag
    end

    def set_fg_color(color_index, prefix = nil)
      @fg_color = get_term_color_class(color_index, ["fg", prefix])
    end

    def set_bg_color(color_index, prefix = nil)
      @bg_color = get_term_color_class(color_index, ["bg", prefix])
    end

    def get_term_color_class(color_index, prefix)
      color_name = COLOR[color_index]
      return nil if color_name.nil?

      return get_color_class(["term", prefix, color_name])
    end

    def set_fg_color_256(command_stack)
      css_class = get_xterm_color_class(command_stack, "fg")
      @fg_color = css_class unless css_class.nil?
    end

    def set_bg_color_256(command_stack)
      css_class = get_xterm_color_class(command_stack, "bg")
      @bg_color = css_class unless css_class.nil?
    end

    def get_xterm_color_class(command_stack, prefix)
      # the 38 and 48 commands have to be followed by "5" and the color index
      return unless command_stack.length >= 2
      return unless command_stack[0] == "5"

      command_stack.shift() # ignore the "5" command
      color_index = command_stack.shift().to_i

      return unless color_index >= 0
      return unless color_index <= 255

      return get_color_class(["xterm", prefix, color_index])
    end

    def get_color_class(segments)
      return [segments].flatten.compact.join('-')
    end

    def beautify_duration(duration)
      "#{duration.round(2)}s"
    end
  end
end
