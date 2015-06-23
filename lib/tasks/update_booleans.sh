psql -c 'update organisms set has_proteins = false' swisspalm
psql -c 'update organisms set has_proteins = true where exists(select * from proteins where proteins.organism_id = organisms.id)' swisspalm

psql -c 'update proteins set has_hits = false' swisspalm
psql -c 'update proteins set has_hits = true where exists(select * from hits where hits.protein_id = proteins.id)' swisspalm

psql -c 'update proteins set has_hits_ortho_public = false' swisspalm
psql -c 'update proteins set has_hits_ortho_public = true where exists(select * from palmitome_entries where palmitome_entries.protein_id = proteins.id)' swisspalm

psql -c 'update proteins set has_hits_public = false' swisspalm
psql -c 'update proteins set has_hits_public = true where exists(select * from hits join studies on (studies.id = hits.study_id) where hits.protein_id = proteins.id and studies.hidden is not true)' swisspalm

#psql -c 'update proteins set has_hits_ortho_public = false' swisspalm
#psql -c 'update proteins set has_hits_ortho_public = true where exists(select * from palmitome_entries where palmitome_entries.protein_id = proteins.id and (exists(select * from studies where (id in regexp_split_to_array(palmitome_entries.palmitome_study_ids, E',') or id in regexp_split_to_array(palmitome_entries.targeted_study_ids, E',')) and hidden is not true))' swisspalm

psql -c 'update proteins set has_hits_targeted = false' swisspalm
psql -c 'update proteins set has_hits_targeted = true where exists(select * from hits join studies on (studies.id = hits.study_id) where hits.protein_id = proteins.id and studies.large_scale is not true)' swisspalm

psql -c 'update predictions set hc_pred = false' swisspalm
psql -c 'update predictions set hc_pred = true where palmpred is true or cp_high_cutoff > 0' swisspalm

psql -c 'update proteins set has_hc_pred = false' swisspalm
psql -c 'update proteins set has_hc_pred = true where exists(select * from predictions join isoforms on (isoforms.id = predictions.isoform_id) where hc_pred = true and isoforms.protein_id = proteins.id)' swisspalm
psql -c 'update proteins set has_hc_pred_valid = true where exists(select * from predictions join isoforms on (isoforms.id = predictions.isoform_id) where hc_pred = true and compatible_loc = true and isoforms.protein_id = proteins.id)' swisspalm

psql -c 'update organisms set has_hits = false' swisspalm
psql -c 'update organisms set has_hits = true where exists(select * from proteins where proteins.organism_id = organisms.id and proteins.has_hits is true)' swisspalm

psql -c 'update go_terms set has_palm_protein = true where exists(select * from proteins join protein_go_associations on (protein_go_associations.protein_id = proteins.id) where proteins.has_hits is true and protein_go_associations.go_term_id = go_terms.id)' swisspalm

psql -c 'update proteins set is_a_pat = true where exists(select * from reactions where reactions.protein_id = proteins.id and reactions.is_a_pat is true) and is_a_pat is false' swisspalm

psql -c 'update hit_lists set nber_hits = (select count(*) from hits where hit_list_id = hit_lists.id)' swisspalm
psql -c 'update hits set has_site = true where exists(select * from sites where hit_id = hits.id)' swisspalm
