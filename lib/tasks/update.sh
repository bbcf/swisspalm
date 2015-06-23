## add organism
echo 'load organisms...'
rake swisspalm:load_organisms --trace 2>&1 > log/load_organisms.log

## download primary data
echo 'download...'
rake swisspalm:download --trace 2>&1 > log/download.log

## update uniprot
echo 'update uniprot...'
rake swisspalm:update_uniprot --trace 2>&1 > log/load_uniprot.log

## update closest sp entries
echo 'update closest sp entries...'
rake swisspalm:find_closest_sp_entry --trace 2>&1 > log/find_closest_sp_entry.log

## update refseq - isoform mapping
echo 'load refseq mapping...'
rake swisspalm:load_refseq_mapping --trace 2>&1 > log/load_refseq_mapping.log

## dump sequences to be downloaded
echo 'create_lists_to_download...'
rake swisspalm:create_lists_to_download --trace  2>&1 > log/create_lists_to_download.log

## update features
echo 'load uniprot features...'
rake swisspalm:load_features --trace 2>&1 > log/load_features.log

## download oma groups
echo 'download OMA groups...'
rake swisspalm:download_oma_groups --trace 2>&1 > log/download_oma_groups.log

## load oma groups
echo 'load OMA groups...'
rake swisspalm:load_oma_groups --trace 2>&1 > log/load_oma_groups.log

## download orthodb
echo 'download orthoDB...'
rake swisspalm:download_orthodb --trace 2>&1 > log/download_orthodb.log

## load orthodb
echo 'load orthoDB...'
rake swisspalm:load_orthodb --trace 2>&1 > log/load_orthodb.log

## find best orthologues
echo 'find best orthologues...'
rake swisspalm:find_best_orthologue --trace 2>&1 > log/find_best_orthologue.log

## update cellosaurus
echo 'load cellosaurus...'
rake swisspalm:load_cellosaurus --trace 2>&1 > log/load_cellosaurus.log

## update go
echo 'load go...'
rake swisspalm:load_go --trace 2>&1 > log/load_go.log

## update booleans values
echo 'update booleans...'
sh update_booleans.sh

## update words for protein search tool
echo 'create words...'
rake swisspalm:create_words --trace 2>&1 > log/create_words.log

## create ma alignments for isoforms
echo 'create isoform ma...'
rake swisspalm:create_isoform_ma --trace 2>&1 >log/create_isoform_ma.log

## compute GO term enrichment
echo 'compute go term enrichments...'
rake swisspalm:compute_go_term_enrichments --trace 2>&1 > log/compute_go_term_enrichments.log

## compute GO term pvalues
echo 'compute go term p-values...'
rake swisspalm:compute_go_term_pval --trace 2>&1 > log/compute_go_term_pval.log

## compute blasts
echo 'compute blast...'
rake swisspalm:compute_blast --trace 2>&1 >log/compute_blast.log

## find pat homologues
echo 'find pat and apt homologues...'
rake swisspalm:find_pat_apt_homologues --trace 2>&1 >log/find_pat_apt_homologues.log

## find pat groups
echo 'find pat groups...'
rake swisspalm:find_pat_groups --trace 2>&1 >log/find_pat_groups.log 

## align pat groups
echo 'align pat groups...'
rake swisspalm:align_pat_groups --trace 2>&1 > log/align_pat_groups.log

## update organism stats
echo 'update organism stats...'
rake swisspalm:organism_stats --trace 2>&1 > log/organism_stats.log


