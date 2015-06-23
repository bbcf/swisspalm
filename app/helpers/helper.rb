class Helper
  class << self
   #include Singleton - no need to do this, class objects are singletons
   include ApplicationHelper
   include ActionView::Helpers::TextHelper
   include ActionView::Helpers::UrlHelper
   include ApplicationHelper
  end
end
