  module Fetch
    
    include Parse
    
    protected
    
    def fetch_pubmed(pmid) 
      
      require 'hpricot'
      require 'open-uri'
      
      doc = open("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=#{pmid}&retmode=xml") { |f| Hpricot(f) }
      p_article = doc.at("pubmedarticle")      
      citation= p_article.at("medlinecitation")
      article = citation.at("article")

      results = {}
      pubdate = article.at("journal").at("journalissue").at("pubdate")
       results[:year]=''
      if pubdate.at("year")
        results[:year]=pubdate.at("year").innerHTML
      elsif pubdate.at("medlinedate")
        results[:year]=pubdate.at("medlinedate").innerHTML.split(" ").first
      end
      results[:title]=article.at("articletitle").innerHTML
      authors = article.at("authorlist").search("author")
      first_author = authors.first
      results[:authors]= first_author.at("lastname").innerHTML + " " + first_author.at("initials").innerHTML
      results[:authors]+= " et al." if authors.size > 1

      return results
  
    end
    
    def fetch_uniprot_entry(up_ac)
      
      list_gene_names = []
      page = `wget -q -O - 'http://uniprot.org/uniprot/#{up_ac}.txt'`
#      logger.debug("==>" + up_ac)
      sleep(1)
      lines = page.split("\n")
      h_protein = nil
      
      all_gene_names = ''
      ac =''
      id=''
      description= ''
      tax_id=''
      trembl=nil
      if lines.size > 0 and lines[0].match(/^ID/)
        lines.each do |line|
          if m=line.match(/^ID\s+(.+?)(\w+);/)
            id = m[1]
            trembl = (m[2] == 'Reviewed') ? false: true
          elsif m=line.match(/^AC\s+(.+?);/) and ac==''
            ac = m[1]
          elsif m= line.match(/^DE.+?\w+=(.+)$/)
            description += m[1]
          elsif  m=line.match(/^GN\s+(.+)/)
            all_gene_names += m[1]
          elsif m=line.match(/^OX\s+NCBI_TaxID=(\d+)/)
            tax_id = m[1]
          end
        end
        
        all_gene_names.split(';').each do |section_gene_names|
          t= section_gene_names.split('=')
          list_gene_names.push(t[1].split(/\s*,\s*/))
        end
        list_gene_names.flatten!
        
        tmp_desc = description.split(";")
        tmp_desc2=[]
        tmp_desc2.push(tmp_desc[0])
        (1 .. tmp_desc.size-1).to_a.each do |desc|
          tmp_desc2.push("(#{desc})")
        end
        description = tmp_desc2.join(" ")
        
        organism = Organism.find_by_taxid(tax_id.to_i) 

        h_protein={
          :up_ac => ac,
          :up_id => id.strip,
          :description => description,
          :organism_id => organism.id,
          :has_hits => true,
          :trembl => trembl
        }
        
        return {:h_protein => h_protein, :list_gene_names => list_gene_names}
      else
        return {:h_protein => nil, :list_gene_names => list_gene_names}
      end
    end
    
    def fetch_uniprot_seq(up_ac)
      
      url = "http://www.uniprot.org/uniprot/?query=#{up_ac}&format=fasta&include=yes"
      lines = `wget -q -O - '#{url}'`.split("\n")
      sleep(1)
      h_seq={}
      ac=''
      h_seq = parse_fasta(lines)
      #      lines.each do |l|
      #        if m=l.match(/^>(.+)/)
      #          line = m[1]
      #          fields = line.split("|")
      #          ac = fields[1]
      #          if h_seq[ac]
      #            puts "error with #{ac}"
      #          else
      #            h_seq[ac]=''
      #          end
      #        else
      #          h_seq[ac]+=l
      #        end
      #      end
      return h_seq
    end

    def retrieve_uniprot_entries(outfile)
      browser = Mechanize.new
      job_key = ''
      File.open(outfile) do |message|
        puts message
        page = browser.post('http://www.uniprot.org/batch/', {
                              "file" => message,
                              "url2" => ""
                            }, {})
        
        browser.page().links().each do |link|
          puts link.href
          if link.href and m = link.href.match(/^\/jobs\/(\w+?)\?/)
            job_key = m[1]
            break;
          end
        end
      end
      
      ### get entries                                                                                                                                                                                                     
      
      browser = Mechanize.new
      page = browser.get("http://www.uniprot.org/jobs/#{job_key}")
      tag = 0
      browser.page().links().each do |link|
        puts link.href
        tag=1 if link.href == "/jobs/#{job_key}.fasta"
      end
      while tag==0 do
        page = browser.get("http://www.uniprot.org/jobs/#{job_key}")
        browser.page().links().each do |link|
          puts link.href
          tag=1 if link.href == "./#{job_key}.fasta"
        end
        sleep(60);
      end
    
      return job_key
    end
    
    
  end

