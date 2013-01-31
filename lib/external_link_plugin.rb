
module ExternalLinkPlugin
  module Patches
    module WikiFormatting
      module Textile
        module FormatterPatch
          def self.included(base)
            base.send :include, InstanceMethods
            #base.alias_method_chain :inline_textile_link, :external_link
            base.class_eval do
              alias_method_chain :auto_link!         , :external_link
              alias :inline_auto_link :auto_link!
            end
          end
          module InstanceMethods
            include Redmine::WikiFormatting::LinksHelper
            #include Redmine::WikiFormatting::Textile::Formatter
=begin
            def inline_textile_link( text )
              text.gsub!( LINK_RE ) do |m|
                all,pre,atts,text,title,url,proto,slash,post = $~[1..9]
                if text.include?('<br />')
                  all
                else
                  url, url_title = check_refs( url )
                  title ||= url_title
                  # Idea below : an URL with unbalanced parethesis and
                  # ending by ')' is put into external parenthesis
                  if ( url[-1]==?) and ((url.count("(") - url.count(")")) < 0 ) )
                    url=url[0..-2] # discard closing parenth from url
                    post = ")"+post # add closing parenth to post
                  end
                  atts = pba( atts )
                  atts = " href=\"#{ htmlesc url }#{ slash }\"#{ atts }"
                  atts << " title=\"#{ htmlesc title }\"" if title
                  atts = shelve( atts ) if atts
                  external = (url =~ /^https?:\/\//) ? ' class="external"' : ''
                  "#{ pre }<a#{ atts }#{ external }>HUK!#{ text }</a>#{ post }"
                end
              end
            end
=end
            def auto_link_with_external_link!(text)
              text.gsub!(AUTO_LINK_RE) do
                all, leading, proto, url, post = $&, $1, $2, $3, $6
                if leading =~ /<a\s/i || leading =~ /![<>=]?/
                  # don't replace URL's that are already linked
                  # and URL's prefixed with ! !> !< != (textile images)
                  all
                else
                  # Idea below : an URL with unbalanced parethesis and
                  # ending by ')' is put into external parenthesis
                  if ( url[-1]==?) and ((url.count("(") - url.count(")")) < 0 ) )
                    url=url[0..-2] # discard closing parenth from url
                    post = ")"+post # add closing parenth to post
                  end
                  content = proto + url
                  # href
                  href = "#{proto=="www."?"http://www.":proto}#{url}"
                  href = one_cushion_link_with_external_link(href)
                  href = %Q( href="#{ERB::Util.html_escape href}")
                  # target
                  target = Setting.plugin_external_link['target']
                  target = (target.blank?) ? '' : %Q( target="#{ERB::Util.html_escape target}")
                  %(#{leading}<a class="external" #{href}#{target}>(EL)#{ERB::Util.html_escape content}</a>#{post}).html_safe
                end
              end
            end
            def one_cushion_link_with_external_link(url)
              one_cushion_link = Setting.plugin_external_link['one_cushion_link']
              if (one_cushion_link.present?)
                url = one_cushion_link.gsub /\$\{(\w+)\}/ do
                  all, label = $&, $1
                  case label
                  when 'URL'
                    url
                  else
                    all
                  end
                end
              end
              url
            end
          end
        end
      end
    end
  end
end

