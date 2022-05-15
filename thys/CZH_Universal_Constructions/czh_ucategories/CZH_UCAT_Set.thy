(* Copyright 2021 (C) Mihails Milehins *)

section\<open>Category \<open>Set\<close> and universal constructions\<close>
theory CZH_UCAT_Set
  imports CZH_UCAT_Complete
begin



subsection\<open>Discrete functor with tiny maps to the category \<open>Set\<close>\<close>

lemma (in \<Z>) tm_cf_discrete_cat_Set_if_VLambda_in_Vset:
  assumes "VLambda I F \<in>\<^sub>\<circ> Vset \<alpha>"
  shows "tm_cf_discrete \<alpha> I F (cat_Set \<alpha>)"
proof(intro tm_cf_discreteI)
  from assms have vrange_F_in_Vset: "\<R>\<^sub>\<circ> (VLambda I F) \<in>\<^sub>\<circ> Vset \<alpha>"
    by (auto intro: vrange_in_VsetI)
  show "(\<lambda>i\<in>\<^sub>\<circ>I. cat_Set \<alpha>\<lparr>CId\<rparr>\<lparr>F i\<rparr>) \<in>\<^sub>\<circ> Vset \<alpha>"
  proof(rule vbrelation.vbrelation_Limit_in_VsetI)
    from assms show "\<D>\<^sub>\<circ> (\<lambda>i\<in>\<^sub>\<circ>I. cat_Set \<alpha>\<lparr>CId\<rparr>\<lparr>F i\<rparr>) \<in>\<^sub>\<circ> Vset \<alpha>"
      by (metis vdomain_VLambda vdomain_in_VsetI)
    define Q where
      "Q i =
        (
          if i = 0
          then VPow ((\<Union>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) \<times>\<^sub>\<circ> (\<Union>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i)) 
          else set (F ` elts I)
        )" 
      for i :: V
    have "\<R>\<^sub>\<circ> (\<lambda>i\<in>\<^sub>\<circ>I. cat_Set \<alpha>\<lparr>CId\<rparr>\<lparr>F i\<rparr>) \<subseteq>\<^sub>\<circ> (\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ> set {0, 1\<^sub>\<nat>, 2\<^sub>\<nat>}. Q i)"
    proof(intro vsubsetI, unfold cat_Set_components)
      fix y assume "y \<in>\<^sub>\<circ> \<R>\<^sub>\<circ> (\<lambda>i\<in>\<^sub>\<circ>I. VLambda (Vset \<alpha>) id_Set\<lparr>F i\<rparr>)"
      then obtain i where i: "i \<in>\<^sub>\<circ> I" 
        and y_def: "y = VLambda (Vset \<alpha>) id_Set\<lparr>F i\<rparr>" 
        by auto
      from i have "F i \<in>\<^sub>\<circ> \<R>\<^sub>\<circ> (VLambda I F)" by auto
      with vrange_F_in_Vset have "F i \<in>\<^sub>\<circ> Vset \<alpha>" by auto
      then have y_def: "y = id_Set (F i)" unfolding y_def by auto
      show "y \<in>\<^sub>\<circ> (\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>set {0, 1\<^sub>\<nat>, 2\<^sub>\<nat>}. Q i)"
        unfolding y_def
      proof(intro vproductI, unfold Ball_def; (intro allI impI)?)
        show "\<D>\<^sub>\<circ> (id_Rel (F i)) = set {0, 1\<^sub>\<nat>, 2\<^sub>\<nat>}"  
          by (simp add: id_Rel_def incl_Rel_def three nat_omega_simps)
        fix j assume "j \<in>\<^sub>\<circ> set {0, 1\<^sub>\<nat>, 2\<^sub>\<nat>}"
        then consider \<open>j = 0\<close> | \<open>j = 1\<^sub>\<nat>\<close> | \<open>j = 2\<^sub>\<nat>\<close> by auto
        then show "id_Rel (F i)\<lparr>j\<rparr> \<in>\<^sub>\<circ> Q j"
        proof cases
          case 1
          from i show ?thesis
            unfolding 1
            by 
              (
                subst arr_field_simps(1)[symmetric], 
                unfold id_Rel_components Q_def
              )
              force
        next
          case 2
          from i show ?thesis
            unfolding 2
            by 
              (
                subst arr_field_simps(2)[symmetric], 
                unfold id_Rel_components Q_def
              ) 
              auto
        next
          case 3
          from i show ?thesis
            unfolding 3
            by 
              (
                subst arr_field_simps(3)[symmetric], 
                unfold id_Rel_components Q_def
              ) 
              auto
        qed
      qed (auto simp: id_Rel_def cat_Set_cs_intros)
    qed
    moreover have "(\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ> set {0, 1\<^sub>\<nat>, 2\<^sub>\<nat>}. Q i) \<in>\<^sub>\<circ> Vset \<alpha>"
    proof(rule Limit_vproduct_in_VsetI)
      show "set {0, 1\<^sub>\<nat>, 2\<^sub>\<nat>} \<in>\<^sub>\<circ> Vset \<alpha>" unfolding three[symmetric] by simp
      from assms have "VPow ((\<Union>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) \<times>\<^sub>\<circ> (\<Union>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i)) \<in>\<^sub>\<circ> Vset \<alpha>"
        by 
          (
            intro 
              Limit_VPow_in_VsetI 
              Limit_vtimes_in_VsetI 
              Limit_vifunion_in_Vset_if_VLambda_in_VsetI
          )
          auto
      then show "Q i \<in>\<^sub>\<circ> Vset \<alpha>" if "i \<in>\<^sub>\<circ> set {0, 1\<^sub>\<nat>, 2\<^sub>\<nat>}" for i
        using that vrange_VLambda
        by (auto intro!: vrange_F_in_Vset simp: Q_def nat_omega_simps)
    qed auto
    ultimately show "\<R>\<^sub>\<circ> (\<lambda>i\<in>\<^sub>\<circ>I. cat_Set \<alpha>\<lparr>CId\<rparr>\<lparr>F i\<rparr>) \<in>\<^sub>\<circ> Vset \<alpha>"
      by (meson vsubset_in_VsetI) 
  qed auto
  fix i assume prems: "i \<in>\<^sub>\<circ> I"
  from assms have "\<R>\<^sub>\<circ> (VLambda I F) \<in>\<^sub>\<circ> Vset \<alpha>" by (auto simp: vrange_in_VsetI)
  moreover from prems have "F i \<in>\<^sub>\<circ> \<R>\<^sub>\<circ> (VLambda I F)" by auto
  ultimately show "F i \<in>\<^sub>\<circ> cat_Set \<alpha>\<lparr>Obj\<rparr>" unfolding cat_Set_components by auto    
qed (cs_concl cs_shallow cs_intro: cat_cs_intros assms)+



subsection\<open>Product cone and coproduct cocone for the category \<open>Set\<close>\<close>


subsubsection\<open>Definition and elementary properties\<close>

definition ntcf_Set_obj_prod :: "V \<Rightarrow> V \<Rightarrow> (V \<Rightarrow> V) \<Rightarrow> V"
  where "ntcf_Set_obj_prod \<alpha> I F = ntcf_obj_prod_base 
    (cat_Set \<alpha>) I F (\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) (\<lambda>i. vprojection_arrow I F i)"

definition ntcf_Set_obj_coprod :: "V \<Rightarrow> V \<Rightarrow> (V \<Rightarrow> V) \<Rightarrow> V"
  where "ntcf_Set_obj_coprod \<alpha> I F = ntcf_obj_coprod_base 
    (cat_Set \<alpha>) I F (\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) (\<lambda>i. vcinjection_arrow I F i)"


text\<open>Components.\<close>

lemma ntcf_Set_obj_prod_components:
  shows "ntcf_Set_obj_prod \<alpha> I F\<lparr>NTMap\<rparr> =
    (\<lambda>i\<in>\<^sub>\<circ>:\<^sub>C I\<lparr>Obj\<rparr>. vprojection_arrow I F i)"
    and "ntcf_Set_obj_prod \<alpha> I F\<lparr>NTDom\<rparr> =
    cf_const (:\<^sub>C I) (cat_Set \<alpha>) (\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i)"
    and "ntcf_Set_obj_prod \<alpha> I F\<lparr>NTCod\<rparr> = :\<rightarrow>: I F (cat_Set \<alpha>)"
    and "ntcf_Set_obj_prod \<alpha> I F\<lparr>NTDGDom\<rparr> = :\<^sub>C I"
    and "ntcf_Set_obj_prod \<alpha> I F\<lparr>NTDGCod\<rparr> = cat_Set \<alpha>"
  unfolding ntcf_Set_obj_prod_def ntcf_obj_prod_base_components by simp_all

lemma ntcf_Set_obj_coprod_components:
  shows "ntcf_Set_obj_coprod \<alpha> I F\<lparr>NTMap\<rparr> =
      (\<lambda>i\<in>\<^sub>\<circ>:\<^sub>C I\<lparr>Obj\<rparr>. vcinjection_arrow I F i)"
    and "ntcf_Set_obj_coprod \<alpha> I F\<lparr>NTDom\<rparr> = :\<rightarrow>: I F (cat_Set \<alpha>)"
    and "ntcf_Set_obj_coprod \<alpha> I F\<lparr>NTCod\<rparr> =
      cf_const (:\<^sub>C I) (cat_Set \<alpha>) (\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i)"
    and "ntcf_Set_obj_coprod \<alpha> I F\<lparr>NTDGDom\<rparr> = :\<^sub>C I"
    and "ntcf_Set_obj_coprod \<alpha> I F\<lparr>NTDGCod\<rparr> = cat_Set \<alpha>"
  unfolding ntcf_Set_obj_coprod_def ntcf_obj_coprod_base_components by simp_all


subsubsection\<open>Natural transformation map\<close>

mk_VLambda ntcf_Set_obj_prod_components(1)
  |vsv ntcf_Set_obj_prod_NTMap_vsv[cat_cs_intros]|
  |vdomain ntcf_Set_obj_prod_NTMap_vdomain[cat_cs_simps]|
  |app ntcf_Set_obj_prod_NTMap_app[cat_cs_simps]|

mk_VLambda ntcf_Set_obj_coprod_components(1)
  |vsv ntcf_Set_obj_coprod_NTMap_vsv[cat_cs_intros]|
  |vdomain ntcf_Set_obj_coprod_NTMap_vdomain[cat_cs_simps]|
  |app ntcf_Set_obj_coprod_NTMap_app[cat_cs_simps]|


subsubsection\<open>
Product cone for the category \<open>Set\<close> is a universal cone and product cocone
for the category \<open>Set\<close> is a universal cocone
\<close>

lemma (in \<Z>) tm_cf_discrete_ntcf_obj_prod_base_is_cat_obj_prod:
  \<comment>\<open>See Theorem 5.2 in Chapter Introduction in \cite{hungerford_algebra_2003}.\<close>
  assumes "VLambda I F \<in>\<^sub>\<circ> Vset \<alpha>"
  shows "ntcf_Set_obj_prod \<alpha> I F : 
    (\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) <\<^sub>C\<^sub>F\<^sub>.\<^sub>\<Prod> F : I \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
proof(intro is_cat_obj_prodI is_cat_limitI)

  interpret Set: tm_cf_discrete \<alpha> I F \<open>cat_Set \<alpha>\<close> 
    by (rule tm_cf_discrete_cat_Set_if_VLambda_in_Vset[OF assms])

  let ?F = \<open>ntcf_Set_obj_prod \<alpha> I F\<close>

  show "cf_discrete \<alpha> I F (cat_Set \<alpha>)"
    by (auto simp: cat_small_discrete_cs_intros)
  show F_is_cat_cone: "?F :
    (\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) <\<^sub>C\<^sub>F\<^sub>.\<^sub>c\<^sub>o\<^sub>n\<^sub>e :\<rightarrow>: I F (cat_Set \<alpha>) : :\<^sub>C I \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
      unfolding ntcf_Set_obj_prod_def
  proof(rule Set.tm_cf_discrete_ntcf_obj_prod_base_is_cat_cone)
    show "(\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) \<in>\<^sub>\<circ> cat_Set \<alpha>\<lparr>Obj\<rparr>"
      unfolding cat_Set_components
      by 
        (
          intro 
            Limit_vproduct_in_Vset_if_VLambda_in_VsetI 
            Set.tm_cf_discrete_ObjMap_in_Vset
        ) 
        auto
  qed (intro vprojection_arrow_is_arr Set.tm_cf_discrete_ObjMap_in_Vset)

  interpret F: is_cat_cone 
    \<alpha> \<open>\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i\<close> \<open>:\<^sub>C I\<close> \<open>cat_Set \<alpha>\<close> \<open>:\<rightarrow>: I F (cat_Set \<alpha>)\<close> \<open>?F\<close>
    by (rule F_is_cat_cone)

  fix \<pi>' P' assume prems:
    "\<pi>' : P' <\<^sub>C\<^sub>F\<^sub>.\<^sub>c\<^sub>o\<^sub>n\<^sub>e :\<rightarrow>: I F (cat_Set \<alpha>) : :\<^sub>C I \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"

  let ?\<pi>'i = \<open>\<lambda>i. \<pi>'\<lparr>NTMap\<rparr>\<lparr>i\<rparr>\<close>
  let ?up' = \<open>cat_Set_obj_prod_up I F P' ?\<pi>'i\<close>

  interpret \<pi>': is_cat_cone \<alpha> P' \<open>:\<^sub>C I\<close> \<open>cat_Set \<alpha>\<close> \<open>:\<rightarrow>: I F (cat_Set \<alpha>)\<close> \<pi>'
    by (rule prems(1))

  show "\<exists>!f'.
    f' : P' \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> (\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) \<and>
    \<pi>' = ?F \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) f'"
  proof(intro ex1I conjI; (elim conjE)?)
    show up': "?up' : P' \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> (\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i)" 
    proof(rule cat_Set_obj_prod_up_cat_Set_is_arr)
      show "P' \<in>\<^sub>\<circ> cat_Set \<alpha>\<lparr>Obj\<rparr>" by (auto intro: cat_cs_intros cat_lim_cs_intros)
      fix i assume "i \<in>\<^sub>\<circ> I"
      then show "\<pi>'\<lparr>NTMap\<rparr>\<lparr>i\<rparr> : P' \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> F i"
        by 
          (
            cs_concl cs_shallow
              cs_simp: 
                the_cat_discrete_components(1) 
                cat_cs_simps cat_discrete_cs_simps 
              cs_intro: cat_cs_intros
          )
    qed (rule assms)

    then have P': "P' \<in>\<^sub>\<circ> cat_Set \<alpha>\<lparr>Obj\<rparr>" 
      by (auto intro: cat_cs_intros cat_lim_cs_intros)

    have \<pi>'i_i: "?\<pi>'i i : P' \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> F i" if "i \<in>\<^sub>\<circ> I" for i
      using 
        \<pi>'.ntcf_NTMap_is_arr[unfolded the_cat_discrete_components(1), OF that]
        that
      by 
        (
          cs_prems cs_shallow cs_simp:
            cat_cs_simps cat_discrete_cs_simps the_cat_discrete_components(1)
        )

    from cat_Set_obj_prod_up_cat_Set_is_arr[OF P' assms(1) \<pi>'i_i] have \<pi>'i: 
      "cat_Set_obj_prod_up I F P' ?\<pi>'i : P' \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> (\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i)". 

    show "\<pi>' = ?F \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) ?up'"
    proof(rule ntcf_eqI, rule \<pi>'.is_ntcf_axioms)

      from F_is_cat_cone \<pi>'i show 
        "?F \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) ?up' :
          cf_const (:\<^sub>C I) (cat_Set \<alpha>) P' \<mapsto>\<^sub>C\<^sub>F :\<rightarrow>: I F (cat_Set \<alpha>) : 
          :\<^sub>C I \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
        by (cs_concl cs_shallow cs_intro: cat_cs_intros)

      have dom_lhs: "\<D>\<^sub>\<circ> (\<pi>'\<lparr>NTMap\<rparr>) = :\<^sub>C I\<lparr>Obj\<rparr>"
        by (cs_concl cs_shallow cs_simp: cat_cs_simps)
      from F_is_cat_cone \<pi>'i have dom_rhs: 
        "\<D>\<^sub>\<circ> ((?F \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) ?up')\<lparr>NTMap\<rparr>) = :\<^sub>C I\<lparr>Obj\<rparr>"
        by (cs_concl cs_shallow cs_simp: cat_cs_simps cs_intro: cat_cs_intros)

      show "\<pi>'\<lparr>NTMap\<rparr> = (?F \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) ?up')\<lparr>NTMap\<rparr>"
      proof(rule vsv_eqI, unfold dom_lhs dom_rhs)
        fix i assume prems': "i \<in>\<^sub>\<circ> :\<^sub>C I\<lparr>Obj\<rparr>"
        then have i: "i \<in>\<^sub>\<circ> I" unfolding the_cat_discrete_components by simp
        have [cat_cs_simps]: 
          "vprojection_arrow I F i \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> ?up' = \<pi>'\<lparr>NTMap\<rparr>\<lparr>i\<rparr>"
          by 
            (
              rule cat_Set_cf_comp_proj_obj_prod_up[
                OF P' assms \<pi>'i_i i, symmetric
                ]
            ) 
            auto
        from \<pi>'i prems' show "\<pi>'\<lparr>NTMap\<rparr>\<lparr>i\<rparr> =
          (?F \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) ?up')\<lparr>NTMap\<rparr>\<lparr>i\<rparr>"
          by 
            (
              cs_concl cs_shallow
                cs_simp: cat_cs_simps cat_Rel_cs_simps cs_intro: cat_cs_intros
            )
      qed (auto simp: cat_cs_intros)

    qed simp_all

    fix f' assume prems:
      "f' : P' \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> (\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i)"
      "\<pi>' = ?F \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) f'"
    from prems(2) have \<pi>'_eq_F_f': "\<pi>'\<lparr>NTMap\<rparr>\<lparr>i\<rparr>\<lparr>ArrVal\<rparr>\<lparr>a\<rparr> = 
      (?F \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) f')\<lparr>NTMap\<rparr>\<lparr>i\<rparr>\<lparr>ArrVal\<rparr>\<lparr>a\<rparr>"
      if "i \<in>\<^sub>\<circ> I" and "a \<in>\<^sub>\<circ> P'" for i a
      by simp
    have [cat_Set_cs_simps]: "\<pi>'\<lparr>NTMap\<rparr>\<lparr>i\<rparr>\<lparr>ArrVal\<rparr>\<lparr>a\<rparr> = f'\<lparr>ArrVal\<rparr>\<lparr>a\<rparr>\<lparr>i\<rparr>"
      if "i \<in>\<^sub>\<circ> I" and "a \<in>\<^sub>\<circ> P'" for i a
      using 
        \<pi>'_eq_F_f'[OF that] 
        assms prems that 
        vprojection_arrow_is_arr[OF that(1) assms]
      by 
        (
          cs_prems cs_shallow
            cs_simp: 
              cat_Set_cs_simps 
              cat_cs_simps 
              vprojection_arrow_ArrVal_app 
              the_cat_discrete_components(1) 
            cs_intro: cat_Set_cs_intros cat_cs_intros
        )

    note f' = cat_Set_is_arrD[OF prems(1)]
    note up' = cat_Set_is_arrD[OF up']

    interpret f': arr_Set \<alpha> f' by (rule f'(1))
    interpret u': arr_Set \<alpha> \<open>(cat_Set_obj_prod_up I F P' (app (\<pi>'\<lparr>NTMap\<rparr>)))\<close> 
      by (rule up'(1))

    show "f' = ?up'"
    proof(rule arr_Set_eqI[of \<alpha>])
      have dom_lhs: "\<D>\<^sub>\<circ> (f'\<lparr>ArrVal\<rparr>) = P'" by (simp add: cat_Set_cs_simps f')
      have dom_rhs: 
        "\<D>\<^sub>\<circ> (cat_Set_obj_prod_up I F P' (app (\<pi>'\<lparr>NTMap\<rparr>))\<lparr>ArrVal\<rparr>) = P'"
        by (simp add: cat_Set_cs_simps up')
      show "f'\<lparr>ArrVal\<rparr> = cat_Set_obj_prod_up I F P' (app (\<pi>'\<lparr>NTMap\<rparr>))\<lparr>ArrVal\<rparr>"
      proof(rule vsv_eqI, unfold dom_lhs dom_rhs)
        fix a assume prems': "a \<in>\<^sub>\<circ> P'"
        from prems(1) prems' have "f'\<lparr>ArrVal\<rparr>\<lparr>a\<rparr> \<in>\<^sub>\<circ> (\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i)"
          by (cs_concl cs_shallow cs_intro: cat_Set_cs_intros)
        note f'a = vproductD[OF this]
        from prems' have dom_rhs: 
          "\<D>\<^sub>\<circ> (cat_Set_obj_prod_up I F P' (app (\<pi>'\<lparr>NTMap\<rparr>))\<lparr>ArrVal\<rparr>\<lparr>a\<rparr>) = I"
          by (cs_concl cs_shallow cs_simp: cat_Set_cs_simps)
        show "f'\<lparr>ArrVal\<rparr>\<lparr>a\<rparr> =
          cat_Set_obj_prod_up I F P' (app (\<pi>'\<lparr>NTMap\<rparr>))\<lparr>ArrVal\<rparr>\<lparr>a\<rparr>"
        proof(rule vsv_eqI, unfold f'a dom_rhs)
          fix i assume "i \<in>\<^sub>\<circ> I"
          with prems' show "f'\<lparr>ArrVal\<rparr>\<lparr>a\<rparr>\<lparr>i\<rparr> =
            cat_Set_obj_prod_up I F P' (app (\<pi>'\<lparr>NTMap\<rparr>))\<lparr>ArrVal\<rparr>\<lparr>a\<rparr>\<lparr>i\<rparr>"
            by (cs_concl cs_shallow cs_simp: cat_Set_cs_simps)
        qed (simp_all add: prems' f'a(1) cat_Set_obj_prod_up_ArrVal_app)
      qed auto
    qed (simp_all add: cat_Set_obj_prod_up_components f' up'(1))

  qed

qed

lemma (in \<Z>) tm_cf_discrete_ntcf_obj_prod_base_is_tm_cat_obj_prod:
  \<comment>\<open>See Theorem 5.2 in Chapter Introduction in \cite{hungerford_algebra_2003}.\<close>
  assumes "VLambda I F \<in>\<^sub>\<circ> Vset \<alpha>"
  shows "ntcf_Set_obj_prod \<alpha> I F :
    (\<Prod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) <\<^sub>C\<^sub>F\<^sub>.\<^sub>t\<^sub>m\<^sub>.\<^sub>\<Prod> F : I \<mapsto>\<mapsto>\<^sub>C\<^sub>.\<^sub>t\<^sub>m\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
proof(intro is_tm_cat_obj_prodI)
  from assms show "tm_cf_discrete \<alpha> I F (cat_Set \<alpha>)"
    by (rule tm_cf_discrete_cat_Set_if_VLambda_in_Vset)
  show "ntcf_Set_obj_prod \<alpha> I F :
    vproduct I F <\<^sub>C\<^sub>F\<^sub>.\<^sub>l\<^sub>i\<^sub>m  :\<rightarrow>: I F (cat_Set \<alpha>) : :\<^sub>C I \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
    by 
      (
        rule is_cat_obj_prodD[
          OF tm_cf_discrete_ntcf_obj_prod_base_is_cat_obj_prod[OF assms]
          ]
      )
qed

lemma (in \<Z>) tm_cf_discrete_ntcf_obj_coprod_base_is_cat_obj_coprod:
  \<comment>\<open>See Theorem 5.2 in Chapter Introduction in \cite{hungerford_algebra_2003}.\<close>
  assumes "VLambda I F \<in>\<^sub>\<circ> Vset \<alpha>"
  shows "ntcf_Set_obj_coprod \<alpha> I F :
    F >\<^sub>C\<^sub>F\<^sub>.\<^sub>\<Coprod> (\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) : I \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
proof(intro is_cat_obj_coprodI is_cat_colimitI)

  interpret Set: tm_cf_discrete \<alpha> I F \<open>cat_Set \<alpha>\<close> 
    by (rule tm_cf_discrete_cat_Set_if_VLambda_in_Vset[OF assms])

  let ?F = \<open>ntcf_Set_obj_coprod \<alpha> I F\<close>

  show "cf_discrete \<alpha> I F (cat_Set \<alpha>)"
    by (auto simp: cat_small_discrete_cs_intros)
  show F_is_cat_cocone: "?F :
    :\<rightarrow>: I F (cat_Set \<alpha>) >\<^sub>C\<^sub>F\<^sub>.\<^sub>c\<^sub>o\<^sub>c\<^sub>o\<^sub>n\<^sub>e (\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) : :\<^sub>C I \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
    unfolding ntcf_Set_obj_coprod_def
  proof(rule Set.tm_cf_discrete_ntcf_obj_coprod_base_is_cat_cocone)
    show "(\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) \<in>\<^sub>\<circ> cat_Set \<alpha>\<lparr>Obj\<rparr>"
      unfolding cat_Set_components
      by 
        (
          intro 
            Limit_vdunion_in_Vset_if_VLambda_in_VsetI 
            Set.tm_cf_discrete_ObjMap_in_Vset
        ) 
        auto
  qed (intro vcinjection_arrow_is_arr Set.tm_cf_discrete_ObjMap_in_Vset)
  then interpret F: is_cat_cocone 
    \<alpha> \<open>\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i\<close> \<open>:\<^sub>C I\<close> \<open>cat_Set \<alpha>\<close> \<open>:\<rightarrow>: I F (cat_Set \<alpha>)\<close> \<open>?F\<close> .

  fix \<pi>' P' assume prems:
    "\<pi>' : :\<rightarrow>: I F (cat_Set \<alpha>) >\<^sub>C\<^sub>F\<^sub>.\<^sub>c\<^sub>o\<^sub>c\<^sub>o\<^sub>n\<^sub>e P' : :\<^sub>C I \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"

  let ?\<pi>'i = \<open>\<lambda>i. \<pi>'\<lparr>NTMap\<rparr>\<lparr>i\<rparr>\<close>
  let ?up' = \<open>cat_Set_obj_coprod_up I F P' ?\<pi>'i\<close>

  interpret \<pi>': is_cat_cocone \<alpha> P' \<open>:\<^sub>C I\<close> \<open>cat_Set \<alpha>\<close> \<open>:\<rightarrow>: I F (cat_Set \<alpha>)\<close> \<pi>'
    by (rule prems(1))

  show "\<exists>!f'.
    f' : VSigma I F \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> P' \<and> 
    \<pi>' = ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) f' \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_Set_obj_coprod \<alpha> I F"
  proof(intro ex1I conjI; (elim conjE)?)
    show up': "?up' : (\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> P'" 
    proof(rule cat_Set_obj_coprod_up_cat_Set_is_arr)
      show "P' \<in>\<^sub>\<circ> cat_Set \<alpha>\<lparr>Obj\<rparr>" 
        by (auto intro: cat_cs_intros cat_lim_cs_intros)
      fix i assume "i \<in>\<^sub>\<circ> I"
      then show "\<pi>'\<lparr>NTMap\<rparr>\<lparr>i\<rparr> : F i \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> P'"
        by 
          (
            cs_concl cs_shallow
              cs_simp: 
                cat_cs_simps cat_discrete_cs_simps 
                the_cat_discrete_components(1) 
              cs_intro: cat_cs_intros
          )
    qed (rule assms)

    then have P': "P' \<in>\<^sub>\<circ> cat_Set \<alpha>\<lparr>Obj\<rparr>" 
      by (auto intro: cat_cs_intros cat_lim_cs_intros)

    have \<pi>'i_i: "?\<pi>'i i : F i \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> P'" if "i \<in>\<^sub>\<circ> I" for i
      using 
        \<pi>'.ntcf_NTMap_is_arr[unfolded the_cat_discrete_components(1), OF that]
        that
      by 
        (
          cs_prems cs_shallow cs_simp:
            cat_cs_simps cat_discrete_cs_simps the_cat_discrete_components(1)
        )
    from cat_Set_obj_coprod_up_cat_Set_is_arr[OF P' assms(1) \<pi>'i_i] have \<pi>'i: 
      "?up' : (\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> P'". 

    show "\<pi>' = ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) ?up' \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ?F"
    proof(rule ntcf_eqI, rule \<pi>'.is_ntcf_axioms)
      from F_is_cat_cocone \<pi>'i show 
        "ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) ?up' \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ?F :
          :\<rightarrow>: I F (cat_Set \<alpha>) \<mapsto>\<^sub>C\<^sub>F cf_const (:\<^sub>C I) (cat_Set \<alpha>) P' : 
          :\<^sub>C I \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
        by (cs_concl cs_shallow cs_intro: cat_cs_intros)
      have dom_lhs: "\<D>\<^sub>\<circ> (\<pi>'\<lparr>NTMap\<rparr>) = :\<^sub>C I\<lparr>Obj\<rparr>"
        by (cs_concl cs_shallow cs_simp: cat_cs_simps)
      from F_is_cat_cocone \<pi>'i have dom_rhs: 
        "\<D>\<^sub>\<circ> ((?F \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) ?up')\<lparr>NTMap\<rparr>) = :\<^sub>C I\<lparr>Obj\<rparr>"
        by (cs_concl cs_shallow cs_simp: cat_cs_simps cs_intro: cat_cs_intros)
      show "\<pi>'\<lparr>NTMap\<rparr> = (ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) ?up' \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ?F)\<lparr>NTMap\<rparr>"
      proof(rule vsv_eqI, unfold dom_lhs dom_rhs)
        fix i assume prems': "i \<in>\<^sub>\<circ> :\<^sub>C I\<lparr>Obj\<rparr>"
        then have i: "i \<in>\<^sub>\<circ> I" unfolding the_cat_discrete_components by simp
        have [cat_cs_simps]: 
          "?up' \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> vcinjection_arrow I F i = \<pi>'\<lparr>NTMap\<rparr>\<lparr>i\<rparr>"
          by 
            (
              simp add: cat_Set_cf_comp_coprod_up_vcia[
                OF P' assms \<pi>'i_i i, symmetric
                ]
            ) 
        from \<pi>'i prems' show "\<pi>'\<lparr>NTMap\<rparr>\<lparr>i\<rparr> =
          (ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) ?up' \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ?F)\<lparr>NTMap\<rparr>\<lparr>i\<rparr>"
          by 
            (
              cs_concl cs_shallow
                cs_simp: cat_cs_simps cat_Rel_cs_simps cs_intro: cat_cs_intros
            )
      qed (cs_concl cs_simp: cat_cs_simps cs_intro: V_cs_intros cat_cs_intros)+
    qed simp_all

    fix f' assume prems:
      "f' : (\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> P'"
      "\<pi>' = ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) f' \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ?F"
    from prems(2) have \<pi>'_eq_F_f': "\<pi>'\<lparr>NTMap\<rparr>\<lparr>i\<rparr>\<lparr>ArrVal\<rparr>\<lparr>a\<rparr> =
      (ntcf_const (:\<^sub>C I) (cat_Set \<alpha>) f' \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ?F)\<lparr>NTMap\<rparr>\<lparr>i\<rparr>\<lparr>ArrVal\<rparr>\<lparr>a\<rparr>"
      if "i \<in>\<^sub>\<circ> I" and "a \<in>\<^sub>\<circ> P'" for i a
      by simp
    note f' = cat_Set_is_arrD[OF prems(1)]
    note up' = cat_Set_is_arrD[OF up']
    interpret f': arr_Set \<alpha> f' by (rule f'(1))
    interpret u': arr_Set \<alpha> \<open>(cat_Set_obj_coprod_up I F P' (app (\<pi>'\<lparr>NTMap\<rparr>)))\<close> 
      by (rule up'(1))
    show "f' = ?up'"
    proof(rule arr_Set_eqI[of \<alpha>])
      have dom_lhs: "\<D>\<^sub>\<circ> (f'\<lparr>ArrVal\<rparr>) = (\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i)" 
        by (simp add: cat_Set_cs_simps f')
      have dom_rhs: 
        "\<D>\<^sub>\<circ> (cat_Set_obj_coprod_up I F P' (app (\<pi>'\<lparr>NTMap\<rparr>))\<lparr>ArrVal\<rparr>) = 
          (\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i)"
        by (simp add: cat_Set_cs_simps up')
      show "f'\<lparr>ArrVal\<rparr> = cat_Set_obj_coprod_up I F P' (app (\<pi>'\<lparr>NTMap\<rparr>))\<lparr>ArrVal\<rparr>"
      proof(rule vsv_eqI, unfold dom_lhs dom_rhs)
        fix ix assume prems': "ix \<in>\<^sub>\<circ> (\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i)"
        then obtain i x where ix_def: "ix = \<langle>i, x\<rangle>" 
          and i: "i \<in>\<^sub>\<circ> I" 
          and x: "x \<in>\<^sub>\<circ> F i" 
          by auto
        from assms prems(1) prems' i x show "f'\<lparr>ArrVal\<rparr>\<lparr>ix\<rparr> = 
          cat_Set_obj_coprod_up I F P' (app (\<pi>'\<lparr>NTMap\<rparr>))\<lparr>ArrVal\<rparr>\<lparr>ix\<rparr>"
          unfolding ix_def prems(2)
          by
            (
              cs_concl cs_shallow
                cs_simp:
                  cat_Set_cs_simps cat_cs_simps the_cat_discrete_components(1)
                cs_intro: cat_cs_intros
            )
      qed auto
    qed (simp_all add: cat_Set_obj_coprod_up_components f' up'(1))

  qed

qed

lemma (in \<Z>) ntcf_Set_obj_coprod_is_tm_cat_obj_coprod:
  \<comment>\<open>See Theorem 5.2 in Chapter Introduction in \cite{hungerford_algebra_2003}.\<close>
  assumes "VLambda I F \<in>\<^sub>\<circ> Vset \<alpha>"
  shows "ntcf_Set_obj_coprod \<alpha> I F :
    F >\<^sub>C\<^sub>F\<^sub>.\<^sub>t\<^sub>m\<^sub>.\<^sub>\<Coprod> (\<Coprod>\<^sub>\<circ>i\<in>\<^sub>\<circ>I. F i) : I \<mapsto>\<mapsto>\<^sub>C\<^sub>.\<^sub>t\<^sub>m\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
proof(intro is_tm_cat_obj_coprodI)
  from assms show "tm_cf_discrete \<alpha> I F (cat_Set \<alpha>)"
    by (rule tm_cf_discrete_cat_Set_if_VLambda_in_Vset)
  show "ntcf_Set_obj_coprod \<alpha> I F :
    :\<rightarrow>: I F (cat_Set \<alpha>) >\<^sub>C\<^sub>F\<^sub>.\<^sub>c\<^sub>o\<^sub>l\<^sub>i\<^sub>m VSigma I F : :\<^sub>C I \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
    by 
      (
        rule is_cat_obj_coprodD[
          OF tm_cf_discrete_ntcf_obj_coprod_base_is_cat_obj_coprod[OF assms]
          ]
      )
qed



subsection\<open>Equalizer for the category \<open>Set\<close>\<close>


subsubsection\<open>Definition and elementary properties\<close>

abbreviation ntcf_Set_equalizer_map :: "V \<Rightarrow> V \<Rightarrow> V \<Rightarrow> V \<Rightarrow> V \<Rightarrow> V"
  where "ntcf_Set_equalizer_map \<alpha> a g f i \<equiv>
    (
      i = \<aa>\<^sub>P\<^sub>L\<^sub>2 ?
        incl_Set (vequalizer a g f) a :
        g \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> incl_Set (vequalizer a g f) a
    )"

definition ntcf_Set_equalizer :: "V \<Rightarrow> V \<Rightarrow> V \<Rightarrow> V \<Rightarrow> V \<Rightarrow> V"
  where "ntcf_Set_equalizer \<alpha> a b g f = ntcf_equalizer_base
    (cat_Set \<alpha>) a b g f (vequalizer a g f) (ntcf_Set_equalizer_map \<alpha> a g f)"


text\<open>Components.\<close>

context
  fixes a g f \<alpha> :: V
begin

lemmas ntcf_Set_equalizer_components = 
  ntcf_equalizer_base_components[
      where \<CC>=\<open>cat_Set \<alpha>\<close> 
        and e=\<open>ntcf_Set_equalizer_map \<alpha> a g f\<close>
        and E=\<open>vequalizer a g f\<close>
        and \<aa>=a and \<gg>=g and \<ff>=f,
        folded ntcf_Set_equalizer_def
    ]

end


subsubsection\<open>Natural transformation map\<close>

mk_VLambda ntcf_Set_equalizer_components(1)
  |vsv ntcf_Set_equalizer_NTMap_vsv[cat_Set_cs_intros]|
  |vdomain ntcf_Set_equalizer_NTMap_vdomain[cat_Set_cs_simps]|
  |app ntcf_Set_equalizer_NTMap_app|

lemma ntcf_Set_equalizer_2_NTMap_app_\<aa>[cat_Set_cs_simps]:
  assumes "x = \<aa>\<^sub>P\<^sub>L\<^sub>2"
  shows 
    "ntcf_Set_equalizer \<alpha> a b g f\<lparr>NTMap\<rparr>\<lparr>x\<rparr> =
      incl_Set (vequalizer a g f) a"
  unfolding assms the_cat_parallel_2_components(1) ntcf_Set_equalizer_components 
  by simp

lemma ntcf_Set_equalizer_2_NTMap_app_\<bb>[cat_Set_cs_simps]:
  assumes "x = \<bb>\<^sub>P\<^sub>L\<^sub>2"
  shows 
    "ntcf_Set_equalizer \<alpha> a b g f\<lparr>NTMap\<rparr>\<lparr>x\<rparr> =
      g \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> incl_Set (vequalizer a g f) a"
  unfolding assms the_cat_parallel_2_components(1) ntcf_Set_equalizer_components
  using cat_PL2_ineq
  by auto


subsubsection\<open>Equalizer for the category \<open>Set\<close> is an equalizer\<close>

lemma (in \<Z>) ntcf_Set_equalizer_2_is_cat_equalizer_2:
  assumes "\<gg> : \<aa> \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> \<bb>" and "\<ff> : \<aa> \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> \<bb>" 
  shows "ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> :
    vequalizer \<aa> \<gg> \<ff> <\<^sub>C\<^sub>F\<^sub>.\<^sub>e\<^sub>q (\<aa>,\<bb>,\<gg>,\<ff>) : \<up>\<up>\<^sub>C \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
proof(intro is_cat_equalizer_2I is_cat_equalizerI is_cat_limitI)
  
  let ?II_II = \<open>\<up>\<up>\<rightarrow>\<up>\<up>\<^sub>C\<^sub>F (cat_Set \<alpha>) \<aa>\<^sub>P\<^sub>L\<^sub>2 \<bb>\<^sub>P\<^sub>L\<^sub>2 \<gg>\<^sub>P\<^sub>L \<ff>\<^sub>P\<^sub>L \<aa> \<bb> \<gg> \<ff>\<close>
    and ?II = \<open>\<up>\<up>\<^sub>C \<aa>\<^sub>P\<^sub>L\<^sub>2 \<bb>\<^sub>P\<^sub>L\<^sub>2 \<gg>\<^sub>P\<^sub>L \<ff>\<^sub>P\<^sub>L\<close>

  note \<gg> = cat_Set_is_arrD[OF assms(1)]
  interpret \<gg>: arr_Set \<alpha> \<gg> 
    rewrites "\<gg>\<lparr>ArrDom\<rparr> = \<aa>" and "\<gg>\<lparr>ArrCod\<rparr> = \<bb>"
    by (rule \<gg>(1)) (simp_all add: \<gg>)
  note \<ff> = cat_Set_is_arrD[OF assms(2)]
  interpret \<ff>: arr_Set \<alpha> \<ff> 
    rewrites "\<ff>\<lparr>ArrDom\<rparr> = \<aa>" and "\<ff>\<lparr>ArrCod\<rparr> = \<bb>"
    by (rule \<ff>(1)) (simp_all add: \<ff>)

  note [cat_Set_cs_intros] = \<gg>.arr_Set_ArrDom_in_Vset \<ff>.arr_Set_ArrCod_in_Vset
  
  let ?incl = \<open>incl_Set (vequalizer \<aa> \<gg> \<ff>) \<aa>\<close>

  show \<aa>\<bb>\<gg>\<ff>_is_cat_cone: "ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> :
    vequalizer \<aa> \<gg> \<ff> <\<^sub>C\<^sub>F\<^sub>.\<^sub>c\<^sub>o\<^sub>n\<^sub>e ?II_II : ?II \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
    unfolding ntcf_Set_equalizer_def
  proof
    (
      intro 
        category.cat_ntcf_equalizer_base_is_cat_cone 
        category.cat_cf_parallel_2_cat_equalizer
    )
    from assms show 
      "(\<bb>\<^sub>P\<^sub>L\<^sub>2 = \<aa>\<^sub>P\<^sub>L\<^sub>2 ? ?incl : \<gg> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> ?incl) :
        vequalizer \<aa> \<gg> \<ff> \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> \<bb>"
      by 
        (
          cs_concl
            cs_simp: V_cs_simps 
            cs_intro: 
              V_cs_intros cat_Set_cs_intros cat_cs_intros 
              cat_PL2_ineq[symmetric] 
        )
    show 
      "(\<bb>\<^sub>P\<^sub>L\<^sub>2 = \<aa>\<^sub>P\<^sub>L\<^sub>2 ? ?incl : \<gg> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> ?incl) =
        \<gg> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> (\<aa>\<^sub>P\<^sub>L\<^sub>2 = \<aa>\<^sub>P\<^sub>L\<^sub>2 ? ?incl : \<gg> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> ?incl)"
      by 
        (
          cs_concl 
            cs_simp: V_cs_simps 
            cs_intro: 
              V_cs_intros cat_Set_cs_intros cat_cs_intros 
              cat_PL2_ineq[symmetric] 
        )
    from assms show 
      "(\<bb>\<^sub>P\<^sub>L\<^sub>2 = \<aa>\<^sub>P\<^sub>L\<^sub>2 ? ?incl : \<gg> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> ?incl) =
        \<ff> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> (\<aa>\<^sub>P\<^sub>L\<^sub>2 = \<aa>\<^sub>P\<^sub>L\<^sub>2 ? ?incl : \<gg> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> ?incl)"
      by 
        (
          cs_concl 
            cs_simp: V_cs_simps cat_Set_incl_Set_commute 
            cs_intro: V_cs_intros cat_PL2_ineq[symmetric]
        )
  qed
    (
      cs_concl 
        cs_intro: cat_cs_intros V_cs_intros cat_Set_cs_intros assms 
        cs_simp: V_cs_simps cat_cs_simps cat_Set_components(1)
    )+

  interpret \<aa>\<bb>\<gg>\<ff>: is_cat_cone 
    \<alpha> \<open>vequalizer \<aa> \<gg> \<ff>\<close> ?II \<open>cat_Set \<alpha>\<close> ?II_II \<open>ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff>\<close>
    by (rule \<aa>\<bb>\<gg>\<ff>_is_cat_cone)

  show "\<exists>!f'.
    f' : r' \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> vequalizer \<aa> \<gg> \<ff> \<and> 
    u' = ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const ?II (cat_Set \<alpha>) f'"
    if "u' : r' <\<^sub>C\<^sub>F\<^sub>.\<^sub>c\<^sub>o\<^sub>n\<^sub>e ?II_II : ?II \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>" for u' r'
  proof-
    
    interpret u': is_cat_cone \<alpha> r' ?II \<open>cat_Set \<alpha>\<close> ?II_II u' by (rule that(1))

    have "\<aa>\<^sub>P\<^sub>L\<^sub>2 \<in>\<^sub>\<circ> ?II\<lparr>Obj\<rparr>" 
      unfolding the_cat_parallel_2_components(1) by simp
    from 
      u'.ntcf_NTMap_is_arr[OF this] 
      \<aa>\<bb>\<gg>\<ff>.NTDom.HomCod.cat_cf_parallel_2_cat_equalizer[OF assms] 
    have u'_\<aa>\<^sub>P\<^sub>L_is_arr: "u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr> : r' \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> \<aa>"
      by (cs_prems_atom_step cat_cs_simps)
        (
          cs_prems
            cs_simp: cat_parallel_cs_simps 
            cs_intro: 
              cat_parallel_cs_intros 
              cat_cs_intros
              category.cat_cf_parallel_2_cat_equalizer
        )
    note u'_\<aa>\<^sub>P\<^sub>L = cat_Set_is_arrD[OF u'_\<aa>\<^sub>P\<^sub>L_is_arr]
    interpret u'_\<aa>\<^sub>P\<^sub>L: arr_Set \<alpha> \<open>u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<close> by (rule u'_\<aa>\<^sub>P\<^sub>L(1))

    have "\<bb>\<^sub>P\<^sub>L\<^sub>2 \<in>\<^sub>\<circ> ?II\<lparr>Obj\<rparr>" 
      by (cs_concl cs_shallow cs_intro: cat_parallel_cs_intros)

    from 
      u'.ntcf_NTMap_is_arr[OF this] 
      \<aa>\<bb>\<gg>\<ff>.NTDom.HomCod.cat_cf_parallel_2_cat_equalizer[OF assms]
    have "u'\<lparr>NTMap\<rparr>\<lparr>\<bb>\<^sub>P\<^sub>L\<^sub>2\<rparr> : r' \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> \<bb>"
      by 
        (
          cs_prems cs_shallow
            cs_simp: cat_cs_simps cat_parallel_cs_simps 
            cs_intro: cat_parallel_cs_intros
        )

    note u'_\<gg>u' = cat_cone_cf_par_2_eps_NTMap_app(1)[OF that(1) assms]
    
    define q where "q = [u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<lparr>ArrVal\<rparr>, r', vequalizer \<aa> \<gg> \<ff>]\<^sub>\<circ>"

    have q_components[cat_Set_cs_simps]:  
      "q\<lparr>ArrVal\<rparr> = u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<lparr>ArrVal\<rparr>" 
      "q\<lparr>ArrDom\<rparr> = r'" 
      "q\<lparr>ArrCod\<rparr> = vequalizer \<aa> \<gg> \<ff>"
      unfolding q_def arr_field_simps by (simp_all add: nat_omega_simps)

    from cat_cone_cf_par_2_eps_NTMap_app[OF that(1) assms] have \<gg>u'_eq_\<ff>u':
      "(\<gg> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>)\<lparr>ArrVal\<rparr>\<lparr>x\<rparr> =
        (\<ff> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>)\<lparr>ArrVal\<rparr>\<lparr>x\<rparr>"
      for x 
      by simp

    show ?thesis
    proof(intro ex1I conjI; (elim conjE)?)

      have u'_NTMap_vrange: "\<R>\<^sub>\<circ> (u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<lparr>ArrVal\<rparr>) \<subseteq>\<^sub>\<circ> vequalizer \<aa> \<gg> \<ff>"
      proof(rule vsubsetI)
        fix y assume prems: "y \<in>\<^sub>\<circ> \<R>\<^sub>\<circ> (u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<lparr>ArrVal\<rparr>)"
        then obtain x where x: "x \<in>\<^sub>\<circ> \<D>\<^sub>\<circ> (u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<lparr>ArrVal\<rparr>)" 
          and y_def: "y = u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<lparr>ArrVal\<rparr>\<lparr>x\<rparr>"
          by (blast dest: u'_\<aa>\<^sub>P\<^sub>L.ArrVal.vrange_atD)
        have x: "x \<in>\<^sub>\<circ> r'" 
          by (use x u'_\<aa>\<^sub>P\<^sub>L_is_arr in \<open>cs_prems cs_shallow cs_simp: cat_cs_simps\<close>)          
        from \<gg>u'_eq_\<ff>u'[of x] assms x u'_\<aa>\<^sub>P\<^sub>L_is_arr have [simp]: 
          "\<gg>\<lparr>ArrVal\<rparr>\<lparr>u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<lparr>ArrVal\<rparr>\<lparr>x\<rparr>\<rparr> =
            \<ff>\<lparr>ArrVal\<rparr>\<lparr>u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<lparr>ArrVal\<rparr>\<lparr>x\<rparr>\<rparr>"
          by (cs_prems cs_shallow cs_simp: cat_cs_simps cs_intro: cat_cs_intros)
        from prems u'_\<aa>\<^sub>P\<^sub>L.arr_Set_ArrVal_vrange[unfolded u'_\<aa>\<^sub>P\<^sub>L] show 
          "y \<in>\<^sub>\<circ> vequalizer \<aa> \<gg> \<ff>"
          by (intro vequalizerI, unfold y_def) auto
      qed

      show q_is_arr: "q : r' \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> vequalizer \<aa> \<gg> \<ff>" 
      proof(intro cat_Set_is_arrI arr_SetI)
        show "q\<lparr>ArrCod\<rparr> \<in>\<^sub>\<circ> Vset \<alpha>" 
          by (auto simp: q_components intro: cat_cs_intros cat_lim_cs_intros)
      qed 
        (
          auto 
            simp: 
              cat_Set_cs_simps nat_omega_simps 
              u'_\<aa>\<^sub>P\<^sub>L 
              q_def 
              u'_NTMap_vrange
              \<aa>\<bb>\<gg>\<ff>.NTDom.HomCod.cat_in_Obj_in_Vset
            intro: cat_cs_intros cat_lim_cs_intros
        )  

      from q_is_arr have \<aa>_q:
        "incl_Set (vequalizer \<aa> \<gg> \<ff>) \<aa> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> q : r' \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> \<aa>"
        by
          (
            cs_concl
              cs_simp: cat_cs_simps cat_Set_components(1)
              cs_intro: V_cs_intros cat_cs_intros cat_Set_cs_intros
          )
      interpret arr_Set \<alpha> \<open>incl_Set (vequalizer \<aa> \<gg> \<ff>) \<aa> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> q\<close>
        using \<aa>_q by (auto dest: cat_Set_is_arrD)

      show "u' = ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const ?II (cat_Set \<alpha>) q"
      proof(rule ntcf_eqI)
        from q_is_arr show 
          "ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const ?II (cat_Set \<alpha>) q :
            cf_const ?II (cat_Set \<alpha>) r' \<mapsto>\<^sub>C\<^sub>F 
            ?II_II : ?II \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
          by (cs_concl cs_shallow cs_simp: cat_cs_simps cs_intro: cat_cs_intros)
        have dom_lhs: "\<D>\<^sub>\<circ> (u'\<lparr>NTMap\<rparr>) = ?II\<lparr>Obj\<rparr>" 
          by (cs_concl cs_shallow cs_simp: cat_cs_simps)
        from q_is_arr have dom_rhs:
          "\<D>\<^sub>\<circ> 
            (
              (ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F 
              ntcf_const ?II (cat_Set \<alpha>) q
            )\<lparr>NTMap\<rparr>) =  ?II\<lparr>Obj\<rparr>"
          by (cs_concl cs_shallow cs_simp: cat_cs_simps cs_intro: cat_cs_intros)
        show "u'\<lparr>NTMap\<rparr> =
          (
            ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const ?II (cat_Set \<alpha>) q
          )\<lparr>NTMap\<rparr>"
        proof(rule vsv_eqI, unfold dom_lhs dom_rhs)
          show "vsv ((
            ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const ?II (cat_Set \<alpha>) q
            )\<lparr>NTMap\<rparr>)"
            by (cs_concl cs_intro: cat_cs_intros)
          fix a assume prems: "a \<in>\<^sub>\<circ> ?II\<lparr>Obj\<rparr>"
          have [symmetric, cat_Set_cs_simps]: 
            "u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr> = incl_Set (vequalizer \<aa> \<gg> \<ff>) \<aa> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> q"
          proof(rule arr_Set_eqI[of \<alpha>])
            from u'_\<aa>\<^sub>P\<^sub>L_is_arr have dom_lhs: "\<D>\<^sub>\<circ> (u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<lparr>ArrVal\<rparr>) = r'"
              by 
                (
                  cs_concl cs_shallow 
                    cs_simp: cat_cs_simps cs_intro: cat_cs_intros
                )
            from \<aa>_q have dom_rhs: 
              "\<D>\<^sub>\<circ> ((incl_Set (vequalizer \<aa> \<gg> \<ff>) \<aa> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> q)\<lparr>ArrVal\<rparr>) = r'"
              by 
                (
                  cs_concl cs_shallow 
                    cs_simp: cat_cs_simps cs_intro: cat_cs_intros
                )
            show "u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<lparr>ArrVal\<rparr> =
              (incl_Set (vequalizer \<aa> \<gg> \<ff>) \<aa> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> q)\<lparr>ArrVal\<rparr>"
            proof(rule vsv_eqI, unfold dom_lhs dom_rhs)
              fix a assume prems: "a \<in>\<^sub>\<circ> r'"
              with u'_NTMap_vrange dom_lhs u'_\<aa>\<^sub>P\<^sub>L.ArrVal.vsv_vimageI2 have 
                "u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<lparr>ArrVal\<rparr>\<lparr>a\<rparr> \<in>\<^sub>\<circ> vequalizer \<aa> \<gg> \<ff>"
                by blast
              with prems q_is_arr u'_\<aa>\<^sub>P\<^sub>L_is_arr show 
                "u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>\<lparr>ArrVal\<rparr>\<lparr>a\<rparr> =
                  (incl_Set (vequalizer \<aa> \<gg> \<ff>) \<aa> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> q)\<lparr>ArrVal\<rparr>\<lparr>a\<rparr>"
                by 
                  (
                    cs_concl cs_shallow
                      cs_simp: cat_Set_cs_simps cat_cs_simps 
                      cs_intro: V_cs_intros cat_cs_intros cat_Set_cs_intros
                  )
            qed auto
          qed 
            (
              use u'_\<aa>\<^sub>P\<^sub>L \<aa>_q in \<open>
                cs_concl cs_shallow 
                  cs_intro: cat_Set_is_arrD(1) cs_simp: cat_cs_simps
                \<close>
            )+
          from q_is_arr have u'_NTMap_app_I: "u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr> =
            (
              ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const ?II (cat_Set \<alpha>) q
            )\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr>"
            by 
              (
                cs_concl 
                  cs_intro: cat_cs_intros cat_parallel_cs_intros 
                  cs_simp: cat_Set_cs_simps cat_cs_simps V_cs_simps
              )
          from q_is_arr assms have u'_NTMap_app_sI: "u'\<lparr>NTMap\<rparr>\<lparr>\<bb>\<^sub>P\<^sub>L\<^sub>2\<rparr> =
            (
              ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const ?II (cat_Set \<alpha>) q
            )\<lparr>NTMap\<rparr>\<lparr>\<bb>\<^sub>P\<^sub>L\<^sub>2\<rparr>"
            by 
              (
                cs_concl 
                  cs_simp: cat_Set_cs_simps cat_cs_simps u'_\<gg>u' 
                  cs_intro: 
                    V_cs_intros 
                    cat_cs_intros 
                    cat_Set_cs_intros 
                    cat_parallel_cs_intros
              )
          from prems consider \<open>a = \<aa>\<^sub>P\<^sub>L\<^sub>2\<close> | \<open>a = \<bb>\<^sub>P\<^sub>L\<^sub>2\<close> 
            by (elim the_cat_parallel_2_ObjE)
          then show 
            "u'\<lparr>NTMap\<rparr>\<lparr>a\<rparr> =
              (
                ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F
                ntcf_const ?II (cat_Set \<alpha>) q
              )\<lparr>NTMap\<rparr>\<lparr>a\<rparr>"
            by cases (simp_all add: u'_NTMap_app_I u'_NTMap_app_sI)
        qed auto
      qed (simp_all add: u'.is_ntcf_axioms)
        
      fix f' assume prems:
        "f' : r' \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> vequalizer \<aa> \<gg> \<ff>"
        "u' = ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F ntcf_const ?II (cat_Set \<alpha>) f'"
      from prems(2) have u'_NTMap_app: 
        "u'\<lparr>NTMap\<rparr>\<lparr>x\<rparr> =
          (ntcf_Set_equalizer \<alpha> \<aa> \<bb> \<gg> \<ff> \<bullet>\<^sub>N\<^sub>T\<^sub>C\<^sub>F
          ntcf_const ?II (cat_Set \<alpha>) f')\<lparr>NTMap\<rparr>\<lparr>x\<rparr>"
        for x
        by simp
      have u'_f': 
        "u'\<lparr>NTMap\<rparr>\<lparr>\<aa>\<^sub>P\<^sub>L\<^sub>2\<rparr> = incl_Set (vequalizer \<aa> \<gg> \<ff>) \<aa> \<circ>\<^sub>A\<^bsub>cat_Set \<alpha>\<^esub> f'"
        using u'_NTMap_app[of \<aa>\<^sub>P\<^sub>L\<^sub>2] prems(1)
        by 
          (
            cs_prems
              cs_simp: cat_cs_simps 
              cs_intro: cat_cs_intros cat_parallel_cs_intros
          )
          (
            cs_prems cs_shallow 
              cs_simp: cat_Set_cs_simps cs_intro: cat_parallel_cs_intros
          )

      note f' = cat_Set_is_arrD[OF prems(1)]
      note q = cat_Set_is_arrD[OF q_is_arr]

      interpret f': arr_Set \<alpha> f' using prems(1) by (auto dest: cat_Set_is_arrD)
      interpret q: arr_Set \<alpha> q using q by (auto dest: cat_Set_is_arrD)

      show "f' = q"
      proof(rule arr_Set_eqI[of \<alpha>])
        have dom_lhs: "\<D>\<^sub>\<circ> (f'\<lparr>ArrVal\<rparr>) = r'" by (simp add: cat_Set_cs_simps f')
        from q_is_arr have dom_rhs: "\<D>\<^sub>\<circ> (q\<lparr>ArrVal\<rparr>) = r'" 
          by 
            (
              cs_concl cs_shallow 
                cs_simp: cat_cs_simps cs_intro: cat_Set_cs_intros
            )
        show "f'\<lparr>ArrVal\<rparr> = q\<lparr>ArrVal\<rparr>"
        proof(rule vsv_eqI, unfold dom_lhs dom_rhs)
          fix i assume "i \<in>\<^sub>\<circ> r'"
          with prems(1) show "f'\<lparr>ArrVal\<rparr>\<lparr>i\<rparr> = q\<lparr>ArrVal\<rparr>\<lparr>i\<rparr>"
            by 
              (
                cs_concl
                  cs_simp: 
                    cat_Set_cs_simps cat_cs_simps 
                    q_components u'_f' cat_Set_components(1)
                  cs_intro: V_cs_intros cat_cs_intros cat_Set_cs_intros
              )
        qed auto
      qed 
        (
          use prems(1) q_is_arr in \<open>
            cs_concl cs_shallow
              cs_simp: cat_cs_simps cs_intro: q cat_Set_is_arrD
            \<close>
        )+
    qed
  qed

qed (auto intro: assms)



subsection\<open>The category \<open>Set\<close> is small-complete\<close>

lemma (in \<Z>) cat_small_complete_cat_Set: "cat_small_complete \<alpha> (cat_Set \<alpha>)"
  \<comment>\<open>This lemma appears as a remark on page 113 in
\cite{mac_lane_categories_2010}.\<close>
proof(rule category.cat_small_complete_if_eq_and_obj_prod)
  show "\<exists>E \<epsilon>. \<epsilon> : E <\<^sub>C\<^sub>F\<^sub>.\<^sub>e\<^sub>q (\<aa>,\<bb>,\<gg>,\<ff>) : \<up>\<up>\<^sub>C \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
    if "\<ff> : \<aa> \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> \<bb>" and "\<gg> : \<aa> \<mapsto>\<^bsub>cat_Set \<alpha>\<^esub> \<bb>" for \<aa> \<bb> \<gg> \<ff>
    using ntcf_Set_equalizer_2_is_cat_equalizer_2[OF that(2,1)] by auto
  show "\<exists>P \<pi>. \<pi> : P <\<^sub>C\<^sub>F\<^sub>.\<^sub>\<Prod> A : I \<mapsto>\<mapsto>\<^sub>C\<^bsub>\<alpha>\<^esub> cat_Set \<alpha>"
    if "tm_cf_discrete \<alpha> I A (cat_Set \<alpha>)" for A I
  proof(intro exI, rule tm_cf_discrete_ntcf_obj_prod_base_is_cat_obj_prod)
    interpret tm_cf_discrete \<alpha> I A \<open>cat_Set \<alpha>\<close> by (rule that)
    show "VLambda I A \<in>\<^sub>\<circ> Vset \<alpha>" by (rule tm_cf_discrete_ObjMap_in_Vset)
  qed
qed (rule category_cat_Set)

text\<open>\newpage\<close>

end