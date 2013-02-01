
module ExternalLinkPlugin
  def self.one_cushion_link(pattern, url)
    if (pattern.present?)
      url = pattern.gsub /\$\{(\w+)\}/ do
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
  module Patches
    module RedCloth3Patch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          alias_method_chain :inline_textile_link, :external_link
        end
      end
      module InstanceMethods
        EXTERNAL_LINK_RE = /<a \:redsh\#(\d+)\: class="external">/
        def inline_textile_link_with_external_link( text )
          inline_textile_link_without_external_link( text )
          one_cushion_link_pattern = Setting.plugin_external_link['one_cushion_link']
          target = Setting.plugin_external_link['target']
          target = (target.blank?) ? '' : %Q( target="#{ERB::Util.html_escape target}")
          text.scan( EXTERNAL_LINK_RE ) do
            num = $1
            @shelf[num.to_i - 1].gsub!( /^(.* href=")([^\"]+)(".*)$/ ) do
              prefix, url, suffix = $1, $2, $3
              url =  ExternalLinkPlugin.one_cushion_link(one_cushion_link_pattern, url)
              suffix << target
              "#{prefix}#{url}#{suffix}"
            end
          end
          sleep 3
        end
      end
    end
    module WikiFormatting
      module Textile
        module FormatterPatch
          def self.included(base)
            base.send :include, InstanceMethods
            base.class_eval do
              alias_method_chain :auto_link!         , :external_link
              alias :inline_auto_link :auto_link!
            end
          end
          module InstanceMethods
            include Redmine::WikiFormatting::LinksHelper
            def auto_link_with_external_link!(text)
              one_cushion_link_pattern = Setting.plugin_external_link['one_cushion_link']
              target = Setting.plugin_external_link['target']
              target = (target.blank?) ? '' : %Q( target="#{ERB::Util.html_escape target}")
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
                  href =  ExternalLinkPlugin.one_cushion_link(one_cushion_link_pattern, href)
                  href = %Q( href="#{ERB::Util.html_escape href}")
                  %(#{leading}<a class="external" #{href}#{target}>#{ERB::Util.html_escape content}</a>#{post}).html_safe
                end
              end
            end
          end
        end
      end
    end
  end
end

