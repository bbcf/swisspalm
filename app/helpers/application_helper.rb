module ApplicationHelper

  def uniprot_link(protein)
    return link_to image_tag("uniprot.png", :border => 0, :alt => '', :title => ''), ("http://uniprot.org/uniprot/" + protein.up_ac)  
  end

  def uniprot_status(protein)
    status = (protein.trembl) ? 'unreviewed' : 'reviewed'
    return raw "<span title='#{status}' class='#{status}'></span>"
  end
  
  def format_up_ac(protein)
    return raw "<span style='white-space:nowrap'>" + 
      #session[:proteins].keys.to_json + "---->" + 
      check_box_tag(('protein_' + protein.id.to_s), 0, session[:proteins][protein.id], {:class => 'checkbox_protein', :onclick => "upd_protein_cart('#{upd_cart_protein_path(protein)}')"}) + 
      "#{uniprot_link(protein)} " +
      link_to(protein.up_ac, protein_path(protein)) + "</span>"
  end

  def format_up_id(protein)
    return link_to(protein.up_id, protein_path(protein)) +
      link_to('UniProt', ('http://uniprot.org/uniprot/' + protein.up_ac), :class => 'small external')
  end

  def format_study_name(study)
    html=''
    if study.pmid and study.pmid!=''
      html+="#{study.authors} (#{study.year})"
    else
      html+="#{study.name}"
    end
    return html  
  end

  def study_link(study)
    return link_to(format_study_name(study),  study_path(study.id))
  end

  def login_logout()
    html= "<div id='login_logout'>"
    if user_signed_in?
      html+="<span>#{current_user.email}</span> | "
      html+=link_to 'Logout', logout_path, :method => :delete
    else
      html+= link_to raw("Login"), login_path, :id => 'login'
    end
    html+="</div>"
    return raw html
  end

  def hit_list_label(hit_list)
    return (hit_list.confidence_level) ? hit_list.confidence_level.tag : 
      ((hit_list.label != '') ? hit_list.label : 'List')
  end

  def display_date(c)
    n = Time.now
    html = "" #<table class='display_date'><tr><td class='day'>"                                                                                                                                              
    if c
      if n.day == c.day and n.month == c.month and n.year == c.year
        html += "Today"
      elsif n.day == c.day + 1 and n.month == c.month and n.year == c.year
        html += "Yesterday"
      else
        html += "#{c.year}-#{"0" if c.month < 10}#{c.month}-#{"0" if c.day < 10}#{c.day}"
      end
      #   html += "</td><td>"                                                                                                                                                                                      
      html += "<br/>at #{"0" if c.hour < 10}#{c.hour}:#{"0" if c.min < 10}#{c.min}" #</td></tr></table>"        
    else
      html += 'NA'
    end
  end


end
