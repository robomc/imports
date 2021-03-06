# Convert <p class="subhead"> => <heading level="2">
PToParagraph = lambda do |env|
  node = env[:node]
  name = env[:node_name]
  return if env[:is_whitelisted] || !node.element?

  if name == 'p'
    node.name = 'paragraph'
  end
end


QuoteStyleForParagraph = lambda do |env|
  node = env[:node]
  name = env[:node_name]
  return if env[:is_whitelisted] || !node.element?

  if name == 'div' && node[:class] == 'quote'
    node.children.css('paragraph').each do |p|
      p[:class] = 'quote'
    end
  end
end



RemoveEmptyParagraphs = lambda do |env|
  node = env[:node]
  name = env[:node_name]
  return if env[:is_whitelisted] || !node.element?

  if name == 'paragraph' && !node.child
    node.remove unless node.text =~ /\d|\w/
  end
end

# Keep the certain p classes.
KeepParagraphClasses = lambda do |env|
    node = env[:node]
    name = env[:node_name]
    return if env[:is_whitelisted] || !node.element?

    classesToKeep = ["small", 'quote,' "Red", "gallery-head", "margin-left"]

    if ( name == 'paragraph' || name == 'p')  && node[:class]
        classes = node[:class].split(' ')
        node.remove_attribute 'class'

        valid = classesToKeep & classes

        unless valid == []
            valid.sort! {|a,b| a <=> b}
            valid_class = valid.join(' ')
            node[:class] = valid_class.downcase
        end

        if valid.length > 1
            Logger.warning "#{valid_class}", "Multiple p classes being added"
        end
    end
end

# Convert <div id="case-nav">Case Study CP909: Healthy, funky, saleable lunches</div> to <p class="reference-heading">Case Study CP909: Healthy, funky, saleable lunches</p>
CaseNavDivToReferenceHeading = lambda do |env|
    node = env[:node]
    name = env[:node_name]
    return if env[:is_whitelisted] || !node.element?

    if name == 'div' && node[:id] == 'case-nav'
      node.name = 'paragraph'
      node[:class] = 'reference-heading'
    end
end

# convert <p style="margin-left:15px;"> to <paragraph class="margin-left">
PStyleToMarginLeft = lambda do |env|
    node = env[:node]
    name = env[:node_name]
    return if env[:is_whitelisted] || !node.element?
    if name == 'p' && node[:style] =~ /margin-left:/
        node.name = 'paragraph'
        node[:class] = 'margin-left'
    end
end


Paragraphs = [PStyleToMarginLeft, KeepParagraphClasses, PToParagraph, QuoteStyleForParagraph, RemoveEmptyParagraphs, CaseNavDivToReferenceHeading]
