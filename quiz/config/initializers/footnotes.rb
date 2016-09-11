if defined?(Footnotes) && Rails.env.development?
  Footnotes.run!; FOOTNOTES_RUN=true;
end