namespace :swisspalm do

  desc "Align pat groups"
  task :align_pat_groups, [:version] do |t, args|

    ### Use rails enviroment
    require "#{Rails.root}/config/environment"

    ### Require Net::HTTP
    require 'net/http'
    require 'uri'
    require "rubygems"
    require 'json'
    require 'bio'
    include Fetch
    include LoadData
    
    orthologues_dir =  Pathname.new(APP_CONFIG[:data_dir]) + 'orthologues'


    blast_dir = orthologues_dir + 'blast_results'
    
    proteins = Protein.find(:all, :conditions => {:is_a_pat => true})    
    h_proteins = {}
    proteins.map{|p| h_proteins[p.id]=p}

    isoforms = Isoform.find(:all, :conditions => {:protein_id => proteins.map{|p| p.id}})
   # h_isoforms = {}
   # isoforms.map{|i| h_isoforms[i.id]=i}
    pat_isoforms = PatIsoform.all
    h_pat_isoforms={}
    pat_isoforms.map{|pi| h_pat_isoforms[pi.isoform_id]= pi}
    all_isoform_ids = isoforms.map{|i| i.id}
    homologues = Homologue.find(:all, :conditions => ["(isoform_id1 in (?) or isoform_id2 in (?)) and (evalue_power is null or evalue_power < -20)", all_isoform_ids, all_isoform_ids])
    puts homologues.size
    
    
    h_homologues={}
    homologues.each do |homologue|
      h_homologues[homologue.isoform_id1]||=[]
      h_homologues[homologue.isoform_id1].push(homologue.isoform_id2) if !h_homologues[homologue.isoform_id1].include?(homologue.isoform_id2)
      h_homologues[homologue.isoform_id2]||=[]
      h_homologues[homologue.isoform_id2].push(homologue.isoform_id1) if !h_homologues[homologue.isoform_id2].include?(homologue.isoform_id1)
    end
    
    groups = {}
    h_groups_by_isoform={}
    isoforms.select{|e| h_pat_isoforms[e.id] and h_pat_isoforms[e.id].homology_group}.each do |isoform|
      pat_isoform = h_pat_isoforms[isoform.id]
      groups[pat_isoform.homology_group]||=[]
      groups[pat_isoform.homology_group].push(isoform.id)
      h_groups_by_isoform[isoform.id] = [pat_isoform.homology_group]
    end
    
    groups.each_key do |gid|
      group = groups[gid]
      
      list_isoform_ids = group
      group.each do |i|
	 
        h_homologues[i].each do |foreign_isoform|
          list_isoform_ids.push(foreign_isoform) if !list_isoform_ids.include?(foreign_isoform)
        end
        
      end
      
      puts "#{gid} => #{list_isoform_ids.join(',')}"

      list_isoforms = Isoform.find(list_isoform_ids)
      h_isoforms={}
      list_isoforms.map{|i| h_isoforms[i.id]=i}
      puts "Do alignment..."
      ##create input file
      infile = orthologues_dir + 'tmp_ma_input.fa'
      File.open(infile, 'w') do |f|
        Isoform.find(list_isoform_ids).each do |isoform|
          protein = isoform.protein #)h_proteins[isoform.protein_id]
          seq = Bio::Sequence::AA.new(isoform.seq)
          f.write(seq.to_fasta(isoform.id.to_s + '|' + protein.up_ac + "-" + isoform.isoform.to_s))
          #       puts seq.to_fasta(isoform.id.to_s + '|' + protein.up_ac + "-" + isoform.isoform)
        end
      end
      
      ali_dir = orthologues_dir + 'alignments'

      outfile = ali_dir + (gid.to_s + ".clw")
      cmd = "mafft --clustalout --quiet  #{infile} > #{outfile}"	
      `#{cmd}`
      
      phylfile=ali_dir + (gid.to_s + ".phyl")
      cmd = "clustalw2phylip #{outfile} > #{phylfile}"
      `#{cmd}`
      cmd = "echo '#{phylfile}\nY\n111\n' | seqboot" 
      `#{cmd}`

      seqbootfile= ali_dir + (gid.to_s + ".seqboot")
      cmd = "mv outfile #{seqbootfile}"
      `#{cmd}`
      
      cmd = "echo '#{seqbootfile}\nm\nd\n10\nY\n' | protdist"
      `#{cmd}`

      protdistfile = ali_dir + (gid.to_s + ".protdist")
      cmd = "mv outfile #{protdistfile}"
      `#{cmd}`

      cmd = "echo '#{protdistfile}\nm\n10\n111\nY\n' | neighbor"
      `#{cmd}`

      neightreefile = ali_dir + (gid.to_s + ".neightree")
      neighoutfile = ali_dir + (gid.to_s + ".neighout")
      cmd = "mv outtree #{neightreefile}"
      `#{cmd}`
      cmd = "mv outfile #{neighoutfile}"
      `#{cmd}`
      
      cmd = "echo '#{neightreefile}\nY\n' | consense"
      `#{cmd}`

      nconstreefile = ali_dir + (gid.to_s + ".neigh.constree")
      nconsoutfile = ali_dir + (gid.to_s + ".neigh.consout")
      cmd = "mv outtree #{nconstreefile}"
      `#{cmd}`
      cmd = "mv outfile #{nconsoutfile}"
      `#{cmd}`
      
      #      cmd = "echo '#{nconstreefile}\nY\n' | drawtree"
      #      `#{cmd}`
      # parse in newick/new hampshire format
      input = Bio::FlatFile.open(Bio::Newick, nconstreefile)
      tree = input.next_entry.tree
      puts tree.nodes.to_json
      puts tree.edges.to_json
      
      #node format : {"name":"133276|Q68","order_number":48}               
      nodes_json = tree.nodes.map{|node|
        tab = (node.name) ? node.name.split("|") : []
	print tab.to_json
	seq_id = ''
        group = 0
	if tab.size > 0
          isoform = h_isoforms[tab[0].to_i]
          protein = isoform.protein
          seq_id = protein.up_ac + ((isoform.main == true) ? '' : "-#{isoform.isoform}") + "(#{protein.up_id})"
          group = protein.organism_id
        end
        {
          :id => node.order_number, 
          :label => seq_id,
          :group => group 
        }
      }.to_json
      
      #edge format : [{"name":"","order_number":160},{"name":"","order_number":161},{"distance":1.0,"distance_string":"1.0"}]        
      edges_json = tree.edges.map{|edge|
        {
          :from=> edge[0].order_number,
          :to => edge[1].order_number,
          :length => edge[2].distance
        }
      }.to_json
      
      jsfile = ali_dir + (gid.to_s + ".neigh.constree.js")
      File.open(jsfile, 'w') do |f|
        f.write("var nodes=" + nodes_json + ";\n")
        f.write("var edges=" + edges_json + ";\n")
      end
      
    end
    
    
    
  end
end
