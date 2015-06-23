  module Compare
    protected
    
    def compare_palmitomes(ref_organism_id, sel_study_ids)
      
      ref_organism_id||=1
      
      organisms = Organism.find(:all, :conditions => {:has_proteins => true})
      
      ref_organism = Organism.find(ref_organism_id)
      
      #### retrieve the orthologies in 1 direction protein lambda (having hits) -> Orthologue in the reference organism                                                                        
      h_orthologues={}
      Orthologue.find(:all,
                      :joins => 'join proteins on (proteins.id = orthologues.protein_id1)',
                      :conditions => {:proteins => {:organism_id => ref_organism.id}}).map{|e|
        h_orthologues[e.protein_id2]||=[];
        h_orthologues[e.protein_id2].push(e.protein_id1)
      }
      
      Orthologue.find(:all,
                      :joins => 'join proteins on (proteins.id = orthologues.protein_id2)',
                      :conditions => {:proteins => {:organism_id => ref_organism.id}}).map{|e|
        h_orthologues[e.protein_id1]||=[];
        h_orthologues[e.protein_id1].push(e.protein_id2)
      }
      
      h_hits={}
      h_studies = {}
      h_cell_types = {}
      h_organisms = {}
      
      h_all_studies = {}

      all_studies = Study.find(:all, :conditions => {:large_scale => true}).select{|e| e.large_scale and e.cell_type and e.organism}.sort{|a, b| [a.organism.name, a.cell_type.name, a] <=> [b.organism.name, b.cell_type.name, b]}.map{|s| h_all_studies[s.id]=s}
      sel_study_ids.delete_if{|e| !all_studies.map{|e2| e2.id}.include?(e)}
      
      ### reject studies that are hidden                                                                                                                                                                                                                                                              
      #all_studies.reject!{|e| e.hidden == true} if !lab_user? and !admin?
      
      studies = []
      if studies.size > 0
        studies = Study.find(:all, :conditions => {:large_scale => true, :id => sel_study_ids})
      else
        studies = Study.find(:all, :conditions => {:large_scale => true})
      end
      
      studies= studies.select{|e| e.large_scale and e.cell_type and e.organism}.sort{|a, b|
        [a.organism.name, a.cell_type.name, a] <=> [b.organism.name, b.cell_type.name, b]}

      #      if !params[:nber_studies] or params[:nber_studies].to_i > studies.size
      #        params[:nber_studies] = (@studies.size * 0.7).to_i
      #      end
      
      all_studies.map{|s|
        h_cell_types[s.cell_type_id] = s.cell_type;
        h_organisms[s.organism_id] = s.organism;
        h_studies[s.organism_id]||={}
        h_studies[s.organism_id][s.cell_type_id]||=[]
        h_studies[s.organism_id][s.cell_type_id].push(s)
      }
      studies.map{|s|
        h_hits[s.id]={};
      }
      
      h_confidence_levels={}
      ConfidenceLevel.all.map{|cl| h_confidence_levels[cl.id]=cl}
      
      h_hit_lists = {}
      HitList.find(:all, :conditions => {:study_id => h_hits.keys}).map{|hl| h_hit_lists[hl.id]=hl}
      
      hits=Hit.find(:all, #:joins => 'join proteins on (proteins.id = hits.protein_id)', 
                    :conditions => #[" nber_studies >= ? and 
                    ["hits.study_id in (?)", studies.map{|s| s.id}]) # {:proteins => {:organism_id =>  @organism.id}})                                                                        
      annot_hits=Hit.find(:all, :conditions => {:hit_list_id => nil})
      ### select only hits present in the selected studies                                                                                                                                     
      selected_hits = hits.select{|h| h_hits[h.study_id]}
      
      ## get proteins first pass + complement pass for orthologues and closest sp proteins                                                                                                     
      h_proteins={}
      list_complement_proteins = []
      
      h_closest_proteins = {}
      list_proteins = Protein.find(selected_hits.map{|h| h.protein_id}.uniq)
      Protein.find(list_proteins.map{|p| p.closest_sp_protein_id}).each do |closest_p|
        h_closest_proteins[closest_p.id]=closest_p
      end
      list_proteins.each do |p| # | annot_hits.map{|h| h.protein_id}.uniq).each do |p|
        h_proteins[p.id]=p #if p.organism_id == ref_organism_id
        if p.closest_sp_protein_id and h_closest_proteins[closest_sp_protein_id].nber_cys_max > 0
          list_complement_proteins.push(p.closest_sp_protein_id)
        end
        if p.organism_id != ref_organism_id and h_orthologues[p.id]
          list_complement_proteins+=h_orthologues[p.id]
        end
      end
      proteins2 = Protein.find(list_complement_proteins)
      proteins2.each do |p|
        h_proteins[p.id]=p
      end

      
      ### compute studies by protein and hits by studies and protein taking into account orthology + record of complementary orthologues using closest SP protein                              
      h_study_by_prot={}
      h_compl_orthologues = {}
      selected_hits.map{|h|
        
        ### change protein to the right organism                                                                                                                                               
        #protein_ids = (h_proteins[h.protein_id].organism_id != ref_organism_id.to_i and h_orthologues[h.protein_id]) ? h_orthologues[h.protein_id] : [h.protein_id]
        protein_ids = (h_proteins[h.protein_id].organism_id == ref_organism_id) ?  [h.protein_id] : ((h_orthologues[h.protein_id]) ? h_orthologues[h.protein_id] : [])
        #protein_ids = ((h_orthologues[h.protein_id]) ? (h_orthologues[h.protein_id] | [h.protein_id]) : 
        #               ((h_proteins[h.protein_id].organism_id == ref_organism_id) ? [h.protein_id] : []))
        
        protein_ids.map{|pid|
          new_pid = pid
          if (h_proteins[pid].closest_sp_protein_id)
            new_pid = h_proteins[pid].closest_sp_protein_id
            h_compl_orthologues[new_pid]||=[]
            h_compl_orthologues[new_pid].push(h.protein_id)
          end
          new_pid
        }.each do |protein_id|
          
          if protein_id
            h_study_by_prot[protein_id]||={}
            h_study_by_prot[protein_id][h.study_id]=1 if h_all_studies[h.study_id]
            if h_hits[h.study_id] ## can be not defined for annotated hits that are added up to the palmitome hits to see the proteins having annotations but not present in palmitomes
              h_hits[h.study_id][protein_id]||=[];
              h_hits[h.study_id][protein_id].push(h)
            end
          end
        end
      }

      
      ### apply the complement of orthology (closest SP protein)                                                                                                                               
      tmp_list_proteins = h_study_by_prot.each_key.map{|pid|
        if h_compl_orthologues[pid]
          h_compl_orthologues[pid].each do |hit_pid|
            h_orthologues[hit_pid]||=[]
            h_orthologues[hit_pid].push(pid)
          end
        end
        pid
      }#.select{|pid|
       # h_study_by_prot[pid].keys.size >params[:nber_studies].to_i-1
      #}
      
      ### compute homologues                                                                                                                                                                   
      h_homologues_by_prot = {}
      tmp_list_proteins.each do |pid|
        h_homologues_by_prot[pid]={}
        selected_hits.each do |h|
          if h_orthologues[h.protein_id]
            if h_orthologues[h.protein_id].include?(pid)
              h_homologues_by_prot[pid][h.protein_id]=1 if h.protein_id != pid
              #             h_orthologues[h.protein_id].map{|o| h_homologues_by_prot[pid][o]=1  if o != pid}
            end
          end
        end
      end      
      
      ### discard the proteins that are already taken into account in the orthologues                                                                                                          
      h_represented_protein = {}
      proteins = []
      
      tmp_list_proteins.sort{|a, b| h_study_by_prot[b].keys.size <=> h_study_by_prot[a].keys.size}.each do |p1_id|
        flag_homologue_represented = 0
        h_homologues_by_prot[p1_id].each_key do |p2_id|
          flag_homologue_represented = 1 if h_represented_protein[p2_id]
        end
        if !h_represented_protein[p1_id] or flag_homologue_represented==0
          proteins.push(h_proteins[p1_id]) if h_proteins[p1_id]
        end
        h_represented_protein[p1_id]=1
        if h_homologues_by_prot[h_proteins[p1_id]]
          h_homologues_by_prot[h_proteins[p1_id]].each_key do |p2_id|
            h_represented_protein[p2_id]=1
          end
        end
      end
      
      h_gene_names = {}
      h_targeted_studies = {}
      h_proteins.each_key do |pid|
        h_gene_names[pid]=[]
        h_targeted_studies[pid]=[]
      end
      
  ### compute annotated hits and add related proteins                                                                                                                                                                        

      RefProtein.find(:all, :conditions => {:source_type_id => 1, :protein_id => h_proteins.keys}).map{|rp| h_gene_names[rp.protein_id].push(rp.value)}

      h_annotated_hits={}

      #      annotated_hits = Hit.find(:all, :conditions => {:protein_id => h_proteins.keys, :hit_list_id => nil})                                                                                                              

      ## display the annotated hits even if there is no palmitome hits                                                                                                                                                                                                                                                                                                                                      
      annotated_hits = Hit.find(:all, :conditions => {:hit_list_id => nil})
      tmp_h_proteins = {}
      Protein.find(annotated_hits.map{|ah| ah.protein_id}).map{|p| tmp_h_proteins[p.id]= p} 
      #annotated_hits.reject!{|e| !h_proteins[e.protein_id]}                                                                                                                                                                    

      annotated_hits.map{|h| h_annotated_hits[h.id]=h}

      annotated_sites = Site.find(:all, :conditions => {:hit_id => annotated_hits.map{|e| e.id}})

      complement_protein_ids = []
      targeted_studies = Study.find(:all, :conditions => {:id => annotated_hits.map{|e|
                                        list_ids = (tmp_h_proteins[e.protein_id].organism_id == ref_organism_id) ? [e.protein_id] : ((h_orthologues[e.protein_id]) ? h_orthologues[e.protein_id] : [])
                                        # (h_orthologues[e.protein_id]) ? (h_orthologues[e.protein_id] | [e.protein_id]) : [e.protein_id] 
                                        # ((h_proteins[e.protein_id].organism_id == ref_organism_id) ? [e.protein_id] : [])) 
                                        #(h_orthologues[e.protein_id]) ? (h_orthologues[e.protein_id] | [e.protein_id]) : [e.protein_id]
                                        list_ids.map{|e2|
                                          h_targeted_studies[e2]||=[];
                                          h_targeted_studies[e2].push(e.study_id) if !h_targeted_studies[e2].include?(e.study_id)
                                          complement_protein_ids.push(e2) if !h_proteins[e2] and !h_represented_protein[h_proteins[e2]]
                                        }
                                        e.study_id
                                      }.uniq})

      proteins+=Protein.find(complement_protein_ids).select{|p| p.organism_id==ref_organism_id}.map{|p|
        h_proteins[p.id]=p
        h_study_by_prot[p.id]={}
        h_homologues_by_prot[p.id]={}
        p
      }
      
      all_targeted_and_palmitome_study_ids = (annotated_hits.map{|e| e.study_id} + all_studies.map{|e| e.id}).uniq
      
      techniques = Technique.find(:all, :select => 'study_id, technique_id', :joins => 'join studies_techniques on (technique_id = techniques.id)', :conditions => {:studies_techniques => {:study_id => h_hits.keys}})# @annotated_hits.map{|e| e.study_id}}})                                                                                                                           
      h_techniques_by_study = {}
      techniques.select{|e| e.technique_id}.map{|e|
        technique_id = (e.technique_id.to_i == 2) ? 1 : e.technique_id.to_i;
        h_techniques_by_study[e.study_id.to_i]||=[];
        h_techniques_by_study[e.study_id.to_i].push(technique_id) if !h_techniques_by_study[e.study_id.to_i].include?(technique_id) #and technique_id != nil                                 
      }
           
      results = []

      proteins.map{|e|
        hit_list={}
        studies.each do |study|
          if (h_hits[study.id][e.id])
            hits = h_hits[study.id][e.id]
            hit_list[study.id] = hits.map{ |h|
              hl = h_hit_lists[h.hit_list_id]
              (hl) ? hl.id : nil
              #(hl) ? (
              #        (hl.confidence_level_id) ? h_confidence_levels[hl.confidence_level_id].tag : ((hl.label!= '') ? hl.label : 'Yes')
              #        ) : 'Paper'
            }.uniq
          #}#.join(", ")
          
          #               else
          #  hit_list.push('-')
          end
        end
        
        #         [:orthologue_protein_ids, :palmitome_study_ids, :targeted_study_protein_ids, :technique_ids, :annotated_site_ids].each do |e|
        results.push(
                     {
                       :protein => e,
                       :hit_list => hit_list,
                       :orthologue_protein_ids => h_homologues_by_prot[e.id].keys,
                       :palmitome_study_ids => h_study_by_prot[e.id].keys,
                       :nber_palmitome_studies => h_study_by_prot[e.id].keys.size,
                       :targeted_study_ids => h_targeted_studies[e.id],
                       :targeted_study_ids_prot => h_targeted_studies[e.id].select{|sid| ((h_hits[sid]) ? h_hits[sid].keys.select{|pid| pid == e.id}.size : 0) > 0}, ### targeted study for this specific protein (not take into account the orthologues)
                       :targeted_study_protein_ids => annotated_hits.select{|ah| list_ids = (h_orthologues[ah.protein_id]) ? h_orthologues[ah.protein_id] : [ah.protein_id]; list_ids.include?(e.id)}.map{|ah| ah.protein_id}.flatten.uniq,
                       :technique_ids => (h_targeted_studies[e.id] + h_study_by_prot[e.id].keys).uniq.map{|study_id| h_techniques_by_study[study_id]}.flatten.uniq,
                       :annotated_site_ids => annotated_sites.select{|as| hit = h_annotated_hits[as.hit_id]; (h_orthologues[hit.protein_id] and h_orthologues[hit.protein_id].include?(e.id)) or hit.protein_id == e.id}.map{|e| e.id}
                     })
      }
      
      
      return results
      
    end

  end

