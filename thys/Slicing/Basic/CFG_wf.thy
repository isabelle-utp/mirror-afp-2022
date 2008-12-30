header {* \isaheader{CFG well-formedness} *}

theory CFG_wf imports CFG begin

subsection {* Well-formedness of the abstract CFG *}

locale CFG_wf = CFG _ _ kind valid_edge "(_Entry_)"
  for kind :: "'edge \<Rightarrow> 'state edge_kind"
    and valid_edge :: "'edge \<Rightarrow> bool"
    and Entry :: 'node ("'('_Entry'_')") +
  fixes Def::"'node \<Rightarrow> 'var set"
  fixes Use::"'node \<Rightarrow> 'var set"
  fixes state_val::"'state \<Rightarrow> 'var \<Rightarrow> 'val"
  assumes Entry_empty:"Def (_Entry_) = {} \<and> Use (_Entry_) = {}"
  and CFG_edge_no_Def_equal:
    "\<lbrakk>valid_edge a; V \<notin> Def (sourcenode a); pred (kind a) s\<rbrakk>
     \<Longrightarrow> state_val (transfer (kind a) s) V = state_val s V"
  and CFG_edge_transfer_uses_only_Use:
    "\<lbrakk>valid_edge a; \<forall>V \<in> Use (sourcenode a). state_val s V = state_val s' V;
      pred (kind a) s; pred (kind a) s'\<rbrakk>
      \<Longrightarrow> \<forall>V \<in> Def (sourcenode a). state_val (transfer (kind a) s) V =
                                     state_val (transfer (kind a) s') V"
  and CFG_edge_Uses_pred_equal:
    "\<lbrakk>valid_edge a; pred (kind a) s; 
      \<forall>V \<in> Use (sourcenode a). state_val s V = state_val s' V\<rbrakk>
       \<Longrightarrow> pred (kind a) s'"
  and deterministic:"\<lbrakk>valid_edge a; valid_edge a'; sourcenode a = sourcenode a';
    targetnode a \<noteq> targetnode a'\<rbrakk> 
  \<Longrightarrow> \<exists>Q Q'. kind a = (Q)\<^isub>\<surd> \<and> kind a' = (Q')\<^isub>\<surd> \<and> 
             (\<forall>s. (Q s \<longrightarrow> \<not> Q' s) \<and> (Q' s \<longrightarrow> \<not> Q s))"

begin

lemma [dest!]: "V \<in> Use (_Entry_) \<Longrightarrow> False"
by(simp add:Entry_empty)

lemma [dest!]: "V \<in> Def (_Entry_) \<Longrightarrow> False"
by(simp add:Entry_empty)


lemma CFG_path_no_Def_equal:
  "\<lbrakk>n -as\<rightarrow>* n'; \<forall>n \<in> set (sourcenodes as). V \<notin> Def n; preds (kinds as) s\<rbrakk> 
    \<Longrightarrow> state_val (transfers (kinds as) s) V = state_val s V"
proof(induct arbitrary:s rule:path.induct)
  case (empty_path n)
  thus ?case by(simp add:sourcenodes_def kinds_def)
next
  case (Cons_path n'' as n' a n)
  note IH = `\<And>s. \<lbrakk>\<forall>n\<in>set (sourcenodes as). V \<notin> Def n; preds (kinds as) s\<rbrakk> \<Longrightarrow>
            state_val (transfers (kinds as) s) V = state_val s V`
  from `preds (kinds (a#as)) s` have "pred (kind a) s"
    and "preds (kinds as) (transfer (kind a) s)" by(simp_all add:kinds_def)
  from `\<forall>n\<in>set (sourcenodes (a#as)). V \<notin> Def n`
    have noDef:"V \<notin> Def (sourcenode a)" 
    and all:"\<forall>n\<in>set (sourcenodes as). V \<notin> Def n"
    by(auto simp:sourcenodes_def)
  from `valid_edge a` noDef `pred (kind a) s`
  have "state_val (transfer (kind a) s) V = state_val s V"
    by(rule CFG_edge_no_Def_equal)
  with IH[OF all `preds (kinds as) (transfer (kind a) s)`] show ?case
    by(simp add:kinds_def)
qed

end


end
