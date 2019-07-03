section \<open>Deterministic Rabin Automata Combinations\<close>

theory DRA_Combine
imports "DRA" "../DBA/DBA" "../DCA/DCA"
begin

  global_interpretation intersection_bc: automaton_intersection_trace
    dba.dba dba.alphabet dba.initial dba.transition dba.accepting infs
    dca.dca dca.alphabet dca.initial dca.transition dca.rejecting fins
    dra.dra dra.alphabet dra.initial dra.transition dra.condition "cogen rabin"
    "\<lambda> c\<^sub>1 c\<^sub>2. [(c\<^sub>1 \<circ> fst, c\<^sub>2 \<circ> snd)]"
    defines intersect_bc = intersection_bc.combine
    by (unfold_locales) (simp add: cogen_def rabin_def)

  (* TODO: why are only the constants of the first interpretation folded back correctly? *)
  lemmas intersect_bc_language[simp] = intersection_bc.combine_language[folded DCA.language_def DRA.language_def]
  lemmas intersect_bc_nodes_finite = intersection_bc.combine_nodes_finite[folded DCA.nodes_def DRA.nodes_def]
  lemmas intersect_bc_nodes_card = intersection_bc.combine_nodes_card[folded DCA.nodes_def DRA.nodes_def]

  (* TODO: are there some statements about the rabin constant hidden in here?
    same for gen/cogen, also in other combinations, shouldn't have to unfold those *)
  global_interpretation union_list: automaton_union_list_trace
    dra.dra dra.alphabet dra.initial dra.transition dra.condition "cogen rabin"
    dra.dra dra.alphabet dra.initial dra.transition dra.condition "cogen rabin"
    "\<lambda> cs. do { k \<leftarrow> [0 ..< length cs]; (f, g) \<leftarrow> cs ! k; [(\<lambda> pp. f (pp ! k), \<lambda> pp. g (pp ! k))] }"
    defines union_list = union_list.combine
    by (unfold_locales) (auto simp: cogen_def rabin_def comp_def split_beta)

  lemmas union_list_language = union_list.combine_language
  lemmas union_list_nodes_finite = union_list.combine_nodes_finite
  lemmas union_list_nodes_card = union_list.combine_nodes_card

end