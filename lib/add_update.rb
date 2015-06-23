  module AddUpdate
    include Fetch

    protected

    
    def add_update_sequence(protein, h_seq)
      
      # count =0                                                                                                                  \
      logger.debug('update sequences ' + h_seq.keys.join(','))
      h_seq.each_key do |k|
        iso = -1
        tab = k.split("-")
        ac = tab[0]
        iso = tab[1] if tab.size == 2
        
        h_iso={
          :protein_id => protein.id,
          :isoform => iso,
          :seq => h_seq[k]
        }
        
        isoform = Isoform.find(:first, :conditions => {:protein_id => protein.id, :seq => h_seq[k]})
        if !isoform
          isoform = Isoform.new(h_iso)
          isoform.save
        else
          isoform.update_attributes(h_iso)
          #  count+=1                                                                                                             \          
        end
        
      end
    end
    
    def add_update_reactions(hit, site, transferase_text, is_a_pat)

      if transferase_text

        enzyme_acs = transferase_text.split(/\s*,\s*/)
        
        #### delete obsolete site reactions
        if site
          site.reactions.each do |reaction|
            if !enzyme_acs.include?(reaction.protein.up_ac)
              reaction.destroy
            end
          end
        elsif hit
        #### delete obsolete hit reactions
          hit.reactions.each do |reaction|
            if !enzyme_acs.include?(reaction.protein.up_ac)
              reaction.destroy
            end
          end
        end
        #### add new reactions

        enzyme_acs.each do |enzyme_ac|

          enzyme = Protein.find_by_up_ac(enzyme_ac)
          
          if !enzyme
            ### if enzyme is not found in the database, try retrieve from uniprot (probably a trembl entry)                                                                                    
            #  logger.debug(enzyme_ac)                                                                                                                                                                                           
            h_res = fetch_uniprot_entry(enzyme_ac)
            #  logger.debug(h_res.to_yaml)                                                                                                                                                                                       
            h_prot = h_res[:h_protein]
            enzyme = Protein.find(:first, :conditions => {:up_ac => h_prot[:up_ac]})
            if !enzyme
              enzyme = Protein.new(h_prot)
              enzyme.user_id=current_user.id
              enzyme.save
              
              ### get sequence                                                                                                                                                                                                 
              h_seq = fetch_uniprot_seq(protein.up_ac)
              add_or_update_sequence(enzyme.id, h_seq)
              
              # count =0                                                                                                                                                                                                      
              h_seq.each_key do |k|
                iso = -1
                tab = k.split("-")
               ac = tab[0]
                iso = tab[1] if tab.size == 2
                
                h_iso={
                  :protein_id => protein.id,
                  :isoform => iso,
                  :seq => h_seq[k]
                }
                
                isoform = Isoform.find(:first, :conditions => {:protein_id => protein.id, :seq => h_seq[k]})
                if !isoform
                  isoform = Isoform.new(h_iso)
                  isoform.save
                else
                  isoform.update_attributes(h_iso)
                  #  count+=1                                                                                                                                                                      
                end
                
              end
              
              
            end
          end
          if enzyme
            h_reaction = {
              :site_id => (site) ? site.id : nil,
              :hit_id => (hit) ? hit.id : nil,
              :protein_id => enzyme.id,
              :is_a_pat => is_a_pat
            }
            
            reaction = Reaction.find(:first, :conditions => h_reaction)
            if !reaction
              h_reaction[:curator_id]=current_user.id
              logger.debug(h_reaction.to_json)
              reaction = Reaction.new(h_reaction)
              reaction.save
            end
          end
          
          
        end

        

      end
    end
  end
