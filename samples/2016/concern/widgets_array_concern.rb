module Topics
  module WidgetsArrayConcern
    extend ActiveSupport::Concern

    included do
      def widgets_array
        elements = widgets_array_base
        elements.each_with_index do |content, index|
          elements[index] = case content
            when /\A[\w:]+ #\d+\z/
              widget = ::Widgets::Widget.find_by(id: content.split(' #').last)
              widget.as_incut if widget
            when /<<\*.*?>>/
              { _type: 'Embeds::Widgets::Quote', content: content.sub('<<*', '').sub('>>', ''), align: 'left' }
            when /<<.*?\*>>/
              { _type: 'Embeds::Widgets::Quote', content: content.sub('<<', '').sub('*>>', ''), align: 'right' }
            when /<<.*?>>/
              { _type: 'Embeds::Widgets::Quote', content: content.sub('<<', '').sub('>>', '') }
            else
              { _type: 'Embeds::Widgets::Text', content: content }
          end
        end.compact
      end

      def widgets_array_base
        return [] if body.blank?

        elements = body.split("\n\n")

        # splits on <!-- Widgets::Widget::Text #234 -->, keeps the occurencies
        elements = elements.map do |element|
          element.split(/<!-- ([\w:]+ #\d+) [\w:]*?-->/)
        end.flatten

        # splits on <<quote>>, <<*quote>>, <<quote*>>, keeps the occurencies
        elements = elements.map do |element|
          element.split(/(<<\*?.*?\*?>>)/)
        end.flatten

        elements.map(&:strip).reject(&:empty?)
      end
    end
  end
end
