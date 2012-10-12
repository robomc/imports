# Convert <p class="subhead"> => <heading level="2">
PToParagraph = lambda do |env|
  node = env[:node]
  name = env[:node_name]
  return if env[:is_whitelisted] || !node.element?

  if name == 'p'
    node.name = 'paragraph'
  end
end


RemoveEmptyParagraphs = lambda do |env|
  node = env[:node]
  name = env[:node_name]
  return if env[:is_whitelisted] || !node.element?

  if name == 'paragraph'
    node.remove unless node.text =~ /\d|\w/
  end
end


Paragraphs = [PToParagraph, RemoveEmptyParagraphs]