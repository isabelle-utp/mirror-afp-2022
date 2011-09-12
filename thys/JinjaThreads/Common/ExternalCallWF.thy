(*  Title:      JinjaThreads/Common/ExternalCallWF.thy
    Author:     Andreas Lochbihler
*)

header{* \isaheader{ Properties of external calls in well-formed programs } *}

theory ExternalCallWF imports WellForm "../Framework/FWSemantics" begin

lemma external_WT_defs_is_type:
  assumes "wf_prog wf_md P" and "T\<bullet>M(Ts) :: U"
  shows "is_type P T" and "is_type P U" "set Ts \<subseteq> types P"
using assms by(auto elim: external_WT_defs.cases)

lemma native_call_is_type:
  assumes "wf_prog wf_md P"
  and "P \<turnstile> T native M:Ts\<rightarrow>Tr in T'" 
  shows "is_type P Tr" "is_type P T'" "set Ts \<subseteq> types P"
using assms
by(auto simp add: native_call_def dest: external_WT_defs_is_type)

lemma external_WT_is_type:
  assumes "wf_prog wf_md P" and "P \<turnstile> T\<bullet>M(Ts) :: U" and "is_type P T"
  shows "is_type P U" "set Ts \<subseteq> types P"
using assms
by(auto elim!: external_WT.cases dest: native_call_is_type)

context heap_base begin

lemma WT_red_external_aggr_imp_red_external:
  "\<lbrakk> wf_prog wf_md P; (ta, va, h') \<in> red_external_aggr P t a M vs h; P,h \<turnstile> a\<bullet>M(vs) : U; P,h \<turnstile> t \<surd>t \<rbrakk>
  \<Longrightarrow> P,t \<turnstile> \<langle>a\<bullet>M(vs), h\<rangle> -ta\<rightarrow>ext \<langle>va, h'\<rangle>"
apply(drule tconfD)
apply(erule external_WT'.cases)
apply(erule external_WT.cases)
apply(clarsimp simp add: native_call_def)
apply(erule external_WT_defs.cases)
apply(auto simp add: red_external_aggr_def widen_Class intro: red_external.intros split: split_if_asm)
done

lemma WT_red_external_list_conv:
  "\<lbrakk> wf_prog wf_md P; P,h \<turnstile> a\<bullet>M(vs) : U; P,h \<turnstile> t \<surd>t \<rbrakk>
  \<Longrightarrow> P,t \<turnstile> \<langle>a\<bullet>M(vs), h\<rangle> -ta\<rightarrow>ext \<langle>va, h'\<rangle> \<longleftrightarrow> (ta, va, h') \<in> red_external_aggr P t a M vs h"
by(blast intro: WT_red_external_aggr_imp_red_external red_external_imp_red_external_aggr)

lemma red_external_new_thread_sees:
  "\<lbrakk> wf_prog wf_md P; P,t \<turnstile> \<langle>a\<bullet>M(vs), h\<rangle> -ta\<rightarrow>ext \<langle>va, h'\<rangle>; NewThread t' (C, M', a') h'' \<in> set \<lbrace>ta\<rbrace>\<^bsub>t\<^esub> \<rbrakk>
  \<Longrightarrow> typeof_addr h' a' = \<lfloor>Class C\<rfloor> \<and> (\<exists>T meth D. P \<turnstile> C sees M':[]\<rightarrow>T = meth in D)"
by(fastforce elim!: red_external.cases simp add: widen_Class ta_upd_simps dest: sub_Thread_sees_run)

end

subsection {* Preservation of heap conformance *}

context heap_conf_read begin

lemma hconf_heap_copy_loc_mono:
  assumes "heap_copy_loc a a' al h obs h'"
  and "hconf h"
  and "P,h \<turnstile> a@al : T" "P,h \<turnstile> a'@al : T"
  shows "hconf h'"
proof -
  from `heap_copy_loc a a' al h obs h'` obtain v 
    where read: "heap_read h a al v" 
    and "write": "heap_write h a' al v h'" by cases auto
  from read `P,h \<turnstile> a@al : T` `hconf h` have "P,h \<turnstile> v :\<le> T"
    by(rule heap_read_conf)
  with "write" `hconf h` `P,h \<turnstile> a'@al : T` show ?thesis
    by(rule hconf_heap_write_mono)
qed

lemma hconf_heap_copies_mono:
  assumes "heap_copies a a' als h obs h'"
  and "hconf h"
  and "list_all2 (\<lambda>al T. P,h \<turnstile> a@al : T) als Ts"
  and "list_all2 (\<lambda>al T. P,h \<turnstile> a'@al : T) als Ts"
  shows "hconf h'"
using assms
proof(induct arbitrary: Ts)
  case Nil thus ?case by simp
next
  case (Cons al h ob h' als obs h'')
  note step = `heap_copy_loc a a' al h ob h'`
  from `list_all2 (\<lambda>al T. P,h \<turnstile> a@al : T) (al # als) Ts`
  obtain T Ts' where [simp]: "Ts = T # Ts'"
    and "P,h \<turnstile> a@al : T" "list_all2 (\<lambda>al T. P,h \<turnstile> a@al : T) als Ts'"
    by(auto simp add: list_all2_Cons1)
  from `list_all2 (\<lambda>al T. P,h \<turnstile> a'@al : T) (al # als) Ts`
  have "P,h \<turnstile> a'@al : T" "list_all2 (\<lambda>al T. P,h \<turnstile> a'@al : T) als Ts'" by simp_all
  from step `hconf h` `P,h \<turnstile> a@al : T` `P,h \<turnstile> a'@al : T`
  have "hconf h'" by(rule hconf_heap_copy_loc_mono)
  moreover from step have "h \<unlhd> h'" by(rule hext_heap_copy_loc)
  from `list_all2 (\<lambda>al T. P,h \<turnstile> a@al : T) als Ts'`
  have "list_all2 (\<lambda>al T. P,h' \<turnstile> a@al : T) als Ts'"
    by(rule list_all2_mono)(rule addr_loc_type_hext_mono[OF _ `h \<unlhd> h'`])
  moreover from `list_all2 (\<lambda>al T. P,h \<turnstile> a'@al : T) als Ts'`
  have "list_all2 (\<lambda>al T. P,h' \<turnstile> a'@al : T) als Ts'"
    by(rule list_all2_mono)(rule addr_loc_type_hext_mono[OF _ `h \<unlhd> h'`])
  ultimately show ?case by(rule Cons)
qed

lemma hconf_heap_clone_mono:
  assumes "heap_clone P h a h' res"
  and "hconf h"
  shows "hconf h'"
using `heap_clone P h a h' res`
proof cases
  case ObjFail thus ?thesis using `hconf h`
    by(fastforce intro: hconf_heap_ops_mono dest: typeof_addr_is_type)
next
  case ArrFail thus ?thesis using `hconf h`
    by(fastforce intro: hconf_heap_ops_mono dest: typeof_addr_is_type)
next
  case (ObjClone C h'' a' FDTs obs)
  note FDTs = `P \<turnstile> C has_fields FDTs`
  let ?als = "map (\<lambda>((F, D), Tfm). CField D F) FDTs"
  let ?Ts = "map (\<lambda>(FD, T). fst (the (map_of FDTs FD))) FDTs"
  note `heap_copies a a' ?als h'' obs h'` 
  moreover from `typeof_addr h a = \<lfloor>Class C\<rfloor>` `hconf h` have "is_class P C"
    by(auto dest: typeof_addr_is_type)
  from `new_obj h C = (h'', \<lfloor>a'\<rfloor>)` have "h \<unlhd> h''" "hconf h''"
    by(rule hext_heap_ops hconf_new_obj_mono[OF _ `hconf h` `is_class P C`])+
  note `hconf h''` 
  moreover
  from `typeof_addr h a = \<lfloor>Class C\<rfloor>` FDTs
  have "list_all2 (\<lambda>al T. P,h \<turnstile> a@al : T) ?als ?Ts"
    unfolding list_all2_map1 list_all2_map2 list_all2_refl_conv
    by(fastforce intro: addr_loc_type.intros simp add: has_field_def dest: weak_map_of_SomeI)
  hence "list_all2 (\<lambda>al T. P,h'' \<turnstile> a@al : T) ?als ?Ts"
    by(rule list_all2_mono)(rule addr_loc_type_hext_mono[OF _ `h \<unlhd> h''`])
  moreover from `new_obj h C = (h'', \<lfloor>a'\<rfloor>)` `is_class P C`
  have "typeof_addr h'' a' = \<lfloor>Class C\<rfloor>" by(auto dest: new_obj_SomeD)
  with FDTs have "list_all2 (\<lambda>al T. P,h'' \<turnstile> a'@al : T) ?als ?Ts"
    unfolding list_all2_map1 list_all2_map2 list_all2_refl_conv
    by(fastforce intro: addr_loc_type.intros simp add: has_field_def dest: weak_map_of_SomeI)
  ultimately have "hconf h'" by(rule hconf_heap_copies_mono)
  thus ?thesis using ObjClone by simp
next
  case (ArrClone T n h'' a' FDTs obs)
  note [simp] = `n = array_length h a`
  let ?als = "map (\<lambda>((F, D), Tfm). CField D F) FDTs @ map ACell [0..<n]"
  let ?Ts = "map (\<lambda>(FD, T). fst (the (map_of FDTs FD))) FDTs @ replicate n T"
  note `heap_copies a a' ?als h'' obs h'`
  moreover from `typeof_addr h a = \<lfloor>T\<lfloor>\<rceil>\<rfloor>` `hconf h` have "is_type P (T\<lfloor>\<rceil>)"
    by(auto dest: typeof_addr_is_type)
  from `new_arr h T n = (h'', \<lfloor>a'\<rfloor>)` have "h \<unlhd> h''" "hconf h''"
    by(rule hext_heap_ops hconf_new_arr_mono[OF _ `hconf h` `is_type P (T\<lfloor>\<rceil>)`])+
  note `hconf h''`
  moreover from `h \<unlhd> h''` `typeof_addr h a = \<lfloor>Array T\<rfloor>`
  have type'a: "typeof_addr h'' a = \<lfloor>Array T\<rfloor>"
    and [simp]: "array_length h'' a = array_length h a" by(auto intro: hext_arrD)
  note FDTs = `P \<turnstile> Object has_fields FDTs`
  from type'a FDTs have "list_all2 (\<lambda>al T. P,h'' \<turnstile> a@al : T) ?als ?Ts"
    by(fastforce intro: list_all2_all_nthI addr_loc_type.intros simp add: has_field_def distinct_fst_def list_all2_append list_all2_map1 list_all2_map2 list_all2_refl_conv dest: weak_map_of_SomeI)
  moreover from `new_arr h T n = (h'', \<lfloor>a'\<rfloor>)` `is_type P (T\<lfloor>\<rceil>)`
  have "typeof_addr h'' a' = \<lfloor>Array T\<rfloor>" "array_length h'' a' = array_length h a"
    by(auto dest: new_arr_SomeD)
  hence "list_all2 (\<lambda>al T. P,h'' \<turnstile> a'@al : T) ?als ?Ts" using FDTs
    by(fastforce intro: list_all2_all_nthI addr_loc_type.intros simp add: has_field_def distinct_fst_def list_all2_append list_all2_map1 list_all2_map2 list_all2_refl_conv dest: weak_map_of_SomeI)
  ultimately have "hconf h'" by(rule hconf_heap_copies_mono)
  thus ?thesis using ArrClone by simp
qed

theorem external_call_hconf:
  assumes major: "P,t \<turnstile> \<langle>a\<bullet>M(vs), h\<rangle> -ta\<rightarrow>ext \<langle>va, h'\<rangle>"
  and minor: "P,h \<turnstile> a\<bullet>M(vs) : U" "hconf h"
  shows "hconf h'"
using major minor
by cases(fastforce intro: hconf_heap_clone_mono)+

end

context heap_base begin

primrec conf_extRet :: "'m prog \<Rightarrow> 'heap \<Rightarrow> 'addr extCallRet \<Rightarrow> ty \<Rightarrow> bool" where
  "conf_extRet P h (RetVal v) T = (P,h \<turnstile> v :\<le> T)"
| "conf_extRet P h (RetExc a) T = (P,h \<turnstile> Addr a :\<le> Class Throwable)"
| "conf_extRet P h RetStaySame T = True"

end

context heap_conf begin

lemma red_external_conf_extRet:
  "\<lbrakk> wf_prog wf_md P; P,t \<turnstile> \<langle>a\<bullet>M(vs), h\<rangle> -ta\<rightarrow>ext \<langle>va, h'\<rangle>; P,h \<turnstile> a\<bullet>M(vs) : U; hconf h; preallocated h; P,h \<turnstile> t \<surd>t \<rbrakk>
  \<Longrightarrow> conf_extRet P h' va U"
apply(frule red_external_hext)
apply(drule (1) preallocated_hext)
apply(auto elim!: red_external.cases external_WT.cases external_WT'.cases external_WT_defs_cases simp add: native_call_def)
apply(auto simp add: conf_def tconf_def intro: xcpt_subcls_Throwable dest!: hext_heap_write dest: typeof_addr_heap_clone)
done

end

subsection {* Progress theorems for external calls *}

context heap_progress begin

lemma heap_copy_loc_progress:
  assumes hconf: "hconf h"
  and alconfa: "P,h \<turnstile> a@al : T"
  and alconfa': "P,h \<turnstile> a'@al : T"
  shows "\<exists>v h'. heap_copy_loc a a' al h ([ReadMem a al v, WriteMem a' al v]) h' \<and> P,h \<turnstile> v :\<le> T \<and> hconf h'"
proof -
  from heap_read_total[OF hconf alconfa]
  obtain v where "heap_read h a al v" "P,h \<turnstile> v :\<le> T" by blast
  moreover from heap_write_total[OF alconfa' `P,h \<turnstile> v :\<le> T`] obtain h' where "heap_write h a' al v h'" ..
  moreover hence "hconf h'" using hconf alconfa' `P,h \<turnstile> v :\<le> T` by(rule hconf_heap_write_mono)
  ultimately show ?thesis by(blast intro: heap_copy_loc.intros)
qed

lemma heap_copies_progress:
  assumes "hconf h"
  and "list_all2 (\<lambda>al T. P,h \<turnstile> a@al : T) als Ts"
  and "list_all2 (\<lambda>al T. P,h \<turnstile> a'@al : T) als Ts"
  shows "\<exists>vs h'. heap_copies a a' als h (concat (map (\<lambda>(al, v). [ReadMem a al v, WriteMem a' al v]) (zip als vs))) h' \<and> hconf h'"
using assms
proof(induct als arbitrary: h Ts)
  case Nil thus ?case by(auto intro: heap_copies.Nil)
next
  case (Cons al als)
  from `list_all2 (\<lambda>al T. P,h \<turnstile> a@al : T) (al # als) Ts`
  obtain T' Ts' where [simp]: "Ts = T' # Ts'"
    and "P,h \<turnstile> a@al : T'" "list_all2 (\<lambda>al T. P,h \<turnstile> a@al : T) als Ts'"
    by(auto simp add: list_all2_Cons1)
  from `list_all2 (\<lambda>al T. P,h \<turnstile> a'@al : T) (al # als) Ts`
  have "P,h \<turnstile> a'@al : T'" and "list_all2 (\<lambda>al T. P,h \<turnstile> a'@al : T) als Ts'" by simp_all
  from `hconf h` `P,h \<turnstile> a@al : T'` `P,h \<turnstile> a'@al : T'`
  obtain v h' where "heap_copy_loc a a' al h [ReadMem a al v, WriteMem a' al v] h'"
    and "hconf h'" by(fastforce dest: heap_copy_loc_progress)
  moreover hence "h \<unlhd> h'" by-(rule hext_heap_copy_loc)
  {
    note `hconf h'`
    moreover from `list_all2 (\<lambda>al T. P,h \<turnstile> a@al : T) als Ts'`
    have "list_all2 (\<lambda>al T. P,h' \<turnstile> a@al : T) als Ts'"
      by(rule list_all2_mono)(rule addr_loc_type_hext_mono[OF _ `h \<unlhd> h'`])
    moreover from `list_all2 (\<lambda>al T. P,h \<turnstile> a'@al : T) als Ts'`
    have "list_all2 (\<lambda>al T. P,h' \<turnstile> a'@al : T) als Ts'"
      by(rule list_all2_mono)(rule addr_loc_type_hext_mono[OF _ `h \<unlhd> h'`])
    ultimately have "\<exists>vs h''. heap_copies a a' als h' (concat (map (\<lambda>(al, v). [ReadMem a al v, WriteMem a' al v]) (zip als vs))) h'' \<and> hconf h''"
      by(rule Cons) }
  then obtain vs h''
    where "heap_copies a a' als h' (concat (map (\<lambda>(al, v). [ReadMem a al v, WriteMem a' al v]) (zip als vs))) h''"
    and "hconf h''" by blast
  ultimately
  have "heap_copies a a' (al # als) h ([ReadMem a al v, WriteMem a' al v] @ (concat (map (\<lambda>(al, v). [ReadMem a al v, WriteMem a' al v]) (zip als vs)))) h''"
    by- (rule heap_copies.Cons)
  also have "[ReadMem a al v, WriteMem a' al v] @ (concat (map (\<lambda>(al, v). [ReadMem a al v, WriteMem a' al v]) (zip als vs))) =
            (concat (map (\<lambda>(al, v). [ReadMem a al v, WriteMem a' al v]) (zip (al # als) (v # vs))))" by simp
  finally show ?case using `hconf h''` by blast
qed

lemma heap_clone_progress:
  assumes wf: "wf_prog wf_md P"
  and typea: "typeof_addr h a = \<lfloor>T\<rfloor>"
  and hconf: "hconf h"
  shows "\<exists>h' res. heap_clone P h a h' res"
proof -
  from typea hconf have "is_type P T" by(rule typeof_addr_is_type)
  from typea have "(\<exists>C. T = Class C) \<or> (\<exists>U. T = Array U)"
    by(rule typeof_addr_eq_Some_conv)
  thus ?thesis
  proof
    assume "\<exists>C. T = Class C"
    then obtain C where [simp]: "T = Class C" ..
    obtain h' res where new: "new_obj h C = (h', res)" by(cases "new_obj h C")
    hence "h \<unlhd> h'" by(rule hext_new_obj)
    from `is_type P T` new have "hconf h'"
      using hconf by simp (rule hconf_new_obj_mono) 
    show ?thesis
    proof(cases res)
      case None
      with typea new ObjFail[of h a C h' P]
      show ?thesis by auto
    next
      case (Some a')
      from `is_type P T` have "is_class P C" by simp
      from wf_Fields_Ex[OF wf this]
      obtain FDTs where FDTs: "P \<turnstile> C has_fields FDTs" ..
      let ?als = "map (\<lambda>((F, D), Tfm). CField D F) FDTs"
      let ?Ts = "map (\<lambda>(FD, T). fst (the (map_of FDTs FD))) FDTs"
      from typea FDTs have "list_all2 (\<lambda>al T. P,h \<turnstile> a@al : T) ?als ?Ts"
        unfolding list_all2_map1 list_all2_map2 list_all2_refl_conv
        by(fastforce intro: addr_loc_type.intros simp add: has_field_def dest: weak_map_of_SomeI)
      hence "list_all2 (\<lambda>al T. P,h' \<turnstile> a@al : T) ?als ?Ts"
        by(rule list_all2_mono)(simp add: addr_loc_type_hext_mono[OF _ `h \<unlhd> h'`] split_def)
      moreover from new Some `is_class P C`
      have "typeof_addr h' a' = \<lfloor>Class C\<rfloor>" by(auto dest: new_obj_SomeD)
      with FDTs have "list_all2 (\<lambda>al T. P,h' \<turnstile> a'@al : T) ?als ?Ts"
        unfolding list_all2_map1 list_all2_map2 list_all2_refl_conv
        by(fastforce intro: addr_loc_type.intros map_of_SomeI simp add: has_field_def dest: weak_map_of_SomeI)
      ultimately obtain obs h'' where "heap_copies a a' ?als h' obs h''" "hconf h''"
        by(blast dest: heap_copies_progress[OF `hconf h'`])
      with typea new Some FDTs ObjClone[of h a C h' a' P FDTs obs h'']
      show ?thesis by auto
    qed
  next
    assume "\<exists>U. T = Array U"
    then obtain U where T [simp]: "T = Array U" ..
    obtain h' res where new: "new_arr h U (array_length h a) = (h', res)"
      by(cases "new_arr h U (array_length h a)")
    hence "h \<unlhd> h'" by(rule hext_new_arr)
    from new hconf `is_type P T` have "hconf h'"
      by(simp del: is_type.simps)(rule hconf_new_arr_mono)
    show ?thesis
    proof(cases res)
      case None
      with typea new ArrFail[of h a U h' P]
      show ?thesis by auto
    next
      case (Some a')
      from wf
      obtain FDTs where FDTs: "P \<turnstile> Object has_fields FDTs"
        by(blast dest: wf_Fields_Ex is_class_Object)
      let ?n = "array_length h a"
      let ?als = "map (\<lambda>((F, D), Tfm). CField D F) FDTs @ map ACell [0..<?n]"
      let ?Ts = "map (\<lambda>(FD, T). fst (the (map_of FDTs FD))) FDTs @ replicate ?n U"
      from `h \<unlhd> h'` typea have type'a: "typeof_addr h' a = \<lfloor>Array U\<rfloor>"
        and [simp]: "array_length h' a = array_length h a" by(auto intro: hext_arrD)
      from type'a FDTs have "list_all2 (\<lambda>al T. P,h' \<turnstile> a@al : T) ?als ?Ts"
        by(fastforce intro: list_all2_all_nthI addr_loc_type.intros simp add: has_field_def list_all2_append list_all2_map1 list_all2_map2 list_all2_refl_conv dest: weak_map_of_SomeI)
      moreover from new Some `is_type P T`
      have "typeof_addr h' a' = \<lfloor>Array U\<rfloor>" "array_length h' a' = array_length h a"
        by(auto dest: new_arr_SomeD)
      hence "list_all2 (\<lambda>al T. P,h' \<turnstile> a'@al : T) ?als ?Ts" using FDTs
        by(fastforce intro: list_all2_all_nthI addr_loc_type.intros simp add: has_field_def list_all2_append list_all2_map1 list_all2_map2 list_all2_refl_conv dest: weak_map_of_SomeI)
      ultimately obtain obs h'' where "heap_copies a a' ?als h' obs h''" "hconf h''"
        by(blast dest: heap_copies_progress[OF `hconf h'`])
      with typea new Some FDTs ArrClone[of h a U "?n" h' a' P FDTs obs h'']
      show ?thesis by auto
    qed
  qed
qed

theorem external_call_progress:
  assumes wf: "wf_prog wf_md P"
  and wt: "P,h \<turnstile> a\<bullet>M(vs) : U"
  and hconf: "hconf h"
  shows "\<exists>ta va h'. P,t \<turnstile> \<langle>a\<bullet>M(vs), h\<rangle> -ta\<rightarrow>ext \<langle>va, h'\<rangle>"
proof -
  note [simp del] = split_paired_Ex
  from wt obtain T Ts Ts'
    where T: "typeof_addr h a = \<lfloor>T\<rfloor>" and Ts: "map typeof\<^bsub>h\<^esub> vs = map Some Ts"
    and "P \<turnstile> T\<bullet>M(Ts') :: U" and subTs: "P \<turnstile> Ts [\<le>] Ts'"
    unfolding external_WT'_iff by blast
  from `P \<turnstile> T\<bullet>M(Ts') :: U` obtain T' where native: "P \<turnstile> T native M:Ts' \<rightarrow> U in T'" by cases
  hence "T'\<bullet>M(Ts') :: U" and subT': "P \<turnstile> T \<le> T'"
    by(auto simp add: is_native_def2 native_call_def)
  from `T'\<bullet>M(Ts') :: U` subT' native T Ts subTs show ?thesis
  proof cases
    assume [simp]: "T' = Class Object" "M = clone" "Ts' = []" "U = Class Object"
    from heap_clone_progress[OF wf T hconf] obtain h' res where "heap_clone P h a h' res" by blast
    thus ?thesis using subTs Ts by(cases res)(auto intro: red_external.intros)
  qed(fastforce simp add: widen_Class intro: red_external.intros dest: native_call_not_NT)+
qed

end

subsection {* Lemmas for preservation of deadlocked threads *}

context heap_progress begin

lemma red_external_wt_hconf_hext:
  assumes wf: "wf_prog wf_md P"
  and red: "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -ta\<rightarrow>ext \<langle>va,h'\<rangle>"
  and hext: "h'' \<unlhd> h"
  and wt: "P,h'' \<turnstile> a\<bullet>M(vs) : U"
  and tconf: "P,h'' \<turnstile> t \<surd>t"
  and hconf: "hconf h''" 
  shows "\<exists>ta' va' h'''. P,t \<turnstile> \<langle>a\<bullet>M(vs),h''\<rangle> -ta'\<rightarrow>ext \<langle>va', h'''\<rangle> \<and> 
                        collect_locks \<lbrace>ta\<rbrace>\<^bsub>l\<^esub> = collect_locks \<lbrace>ta'\<rbrace>\<^bsub>l\<^esub> \<and> 
                        collect_cond_actions \<lbrace>ta\<rbrace>\<^bsub>c\<^esub> = collect_cond_actions \<lbrace>ta'\<rbrace>\<^bsub>c\<^esub> \<and>
                        collect_interrupts \<lbrace>ta\<rbrace>\<^bsub>i\<^esub> = collect_interrupts \<lbrace>ta'\<rbrace>\<^bsub>i\<^esub>"
using red wt hext
proof cases
  case (RedClone obs a')
  from wt obtain T Ts Ts'
    where T: "typeof_addr h'' a = \<lfloor>T\<rfloor>" and "P \<turnstile> T\<bullet>M(Ts') :: U"
    unfolding external_WT'_iff by blast
  from `P \<turnstile> T\<bullet>M(Ts') :: U` obtain T' where "P \<turnstile> T native M:Ts' \<rightarrow> U in T'" by cases
  hence "T'\<bullet>M(Ts') :: U" and subT': "P \<turnstile> T \<le> T'" by(simp_all add: native_call_def)
  from `M = clone` `T'\<bullet>M(Ts') :: U` have [simp]: "T' = Class Object"
    by(auto elim!: external_WT_defs.cases)
  from heap_clone_progress[OF wf T hconf]
  obtain h''' res where "heap_clone P h'' a h''' res" by blast
  thus ?thesis using RedClone
    by(cases res)(fastforce intro: red_external.intros)+
next
  case RedCloneFail
  from wt obtain T Ts Ts'
    where T: "typeof_addr h'' a = \<lfloor>T\<rfloor>" and "P \<turnstile> T\<bullet>M(Ts') :: U"
    unfolding external_WT'_iff by blast
  from `P \<turnstile> T\<bullet>M(Ts') :: U` obtain T' where "P \<turnstile> T native M:Ts' \<rightarrow> U in T'" by cases
  hence "T'\<bullet>M(Ts') :: U" and subT': "P \<turnstile> T \<le> T'" by(simp_all add: native_call_def)
  from `M = clone` `T'\<bullet>M(Ts') :: U` have [simp]: "T' = Class Object"
    by(auto elim!: external_WT_defs.cases)
  from heap_clone_progress[OF wf T hconf]
  obtain h''' res where "heap_clone P h'' a h''' res" by blast
  thus ?thesis using RedCloneFail
    by(cases res)(fastforce intro: red_external.intros)+
qed(fastforce simp add: ta_upd_simps elim!: external_WT'.cases intro: red_external.intros[simplified] dest: typeof_addr_hext_mono)+

lemma red_external_wf_red:
  assumes wf: "wf_prog wf_md P"
  and red: "P,t \<turnstile> \<langle>a\<bullet>M(vs), h\<rangle> -ta\<rightarrow>ext \<langle>va, h'\<rangle>"
  and tconf: "P,h \<turnstile> t \<surd>t"
  and hconf: "hconf h"
  and wst: "wset s t = None \<or> (M = wait \<and> (\<exists>w. wset s t = \<lfloor>PostWS w\<rfloor>))"
  obtains ta' va' h''
  where "P,t \<turnstile> \<langle>a\<bullet>M(vs), h\<rangle> -ta'\<rightarrow>ext \<langle>va', h''\<rangle>" 
  and "final_thread.actions_ok final s t ta' \<or> final_thread.actions_ok' s t ta' \<and> final_thread.actions_subset ta' ta"
proof(atomize_elim)
  let ?a_t = "thread_id2addr t"
  let ?t_a = "addr2thread_id a"

  from tconf obtain C where ht: "typeof_addr h ?a_t = \<lfloor>Class C\<rfloor>" 
    and sub: "P \<turnstile> C \<preceq>\<^sup>* Thread" by(fastforce dest: tconfD)

  show "\<exists>ta' va' h'. P,t \<turnstile> \<langle>a\<bullet>M(vs), h\<rangle> -ta'\<rightarrow>ext \<langle>va', h'\<rangle> \<and> (final_thread.actions_ok final s t ta' \<or> final_thread.actions_ok' s t ta' \<and> final_thread.actions_subset ta' ta)"
  proof(cases "final_thread.actions_ok' s t ta")
    case True
    have "final_thread.actions_subset ta ta" by(rule final_thread.actions_subset_refl)
    with True red show ?thesis by blast
  next
    case False
    note [simp] = final_thread.actions_ok'_iff lock_ok_las'_def final_thread.cond_action_oks'_subset_Join
      final_thread.actions_subset_iff ta_upd_simps collect_cond_actions_def collect_interrupts_def
    note [rule del] = subsetI
    note [intro] = collect_locks'_subset_collect_locks red_external.intros[simplified]

    show ?thesis
    proof(cases "wset s t")
      case (Some w)[simp]
      with wst obtain w' where [simp]: "w = PostWS w'" "M = wait" by auto
      from red have [simp]: "vs = []" by(auto elim: red_external.cases)
      show ?thesis
      proof(cases w')
        case WSWokenUp[simp]
        let ?ta' = "\<lbrace>WokenUp, ClearInterrupt t, ObsInterrupted t\<rbrace>"
        have "final_thread.actions_ok' s t ?ta'" by(simp add: wset_actions_ok_def)
        moreover have "final_thread.actions_subset ?ta' ta"
	  by(auto simp add: collect_locks'_def finfun_upd_apply)
        moreover from RedWaitInterrupted
        have "\<exists>va h'. P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by auto
        ultimately show ?thesis by blast
      next
        case WSNotified[simp]
        let ?ta' = "\<lbrace>Notified\<rbrace>"
        have "final_thread.actions_ok' s t ?ta'" by(simp add: wset_actions_ok_def)
        moreover have "final_thread.actions_subset ?ta' ta"
	  by(auto simp add: collect_locks'_def finfun_upd_apply)
        moreover from RedWaitNotified
        have "\<exists>va h'. P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by auto
        ultimately show ?thesis by blast
      qed
    next
      case None

      from red False show ?thesis
      proof cases
        case (RedNewThread C)
        note ta = `ta = \<lbrace>NewThread ?t_a (C, run, a) h, ThreadStart ?t_a\<rbrace>`
        let ?ta' = "\<lbrace>ThreadExists ?t_a True\<rbrace>"
        from ta False None have "final_thread.actions_ok' s t ?ta'" by(auto)
        moreover from ta have "final_thread.actions_subset ?ta' ta" by(auto)
        ultimately show ?thesis using RedNewThread by(fastforce)
      next
        case RedNewThreadFail
        then obtain va' h' x where "P,t \<turnstile> \<langle>a\<bullet>M(vs), h\<rangle> -\<lbrace>NewThread ?t_a x h', ThreadStart ?t_a\<rbrace>\<rightarrow>ext \<langle>va', h'\<rangle>"
          by(fastforce)
        moreover from `ta = \<lbrace>ThreadExists ?t_a True\<rbrace>` False None
        have "final_thread.actions_ok' s t \<lbrace>NewThread ?t_a x h', ThreadStart ?t_a\<rbrace>" by(auto)
        moreover from `ta = \<lbrace>ThreadExists ?t_a True\<rbrace>`
        have "final_thread.actions_subset \<lbrace>NewThread ?t_a x h', ThreadStart ?t_a\<rbrace> ta" by(auto)
        ultimately show ?thesis by blast
      next
        case RedJoin
        let ?ta = "\<lbrace>IsInterrupted t True, ClearInterrupt t, ObsInterrupted t\<rbrace>"
        from `ta = \<lbrace>Join (addr2thread_id a), IsInterrupted t False, ThreadJoin (addr2thread_id a)\<rbrace>` None False
        have "t \<in> interrupts s" by(auto simp add: interrupt_actions_ok'_def)
        hence "final_thread.actions_ok final s t ?ta"
          using None by(auto simp add: final_thread.actions_ok_iff final_thread.cond_action_oks.simps)
        moreover obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta\<rightarrow>ext \<langle>va,h'\<rangle>" using RedJoinInterrupt RedJoin by auto
        ultimately show ?thesis by blast
      next
        case RedJoinInterrupt
        hence False using False None by(auto)
        thus ?thesis ..
      next
        case RedInterrupt
        let ?ta = "\<lbrace>ThreadExists (addr2thread_id a) False\<rbrace>"
        from RedInterrupt None False
        have "free_thread_id (thr s) (addr2thread_id a)" by(auto simp add: wset_actions_ok_def)
        hence "final_thread.actions_ok final s t ?ta" using None 
          by(auto simp add: final_thread.actions_ok_iff final_thread.cond_action_oks.simps)
        moreover obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta\<rightarrow>ext \<langle>va,h'\<rangle>" using RedInterruptInexist RedInterrupt by auto
        ultimately show ?thesis by blast
      next
        case RedInterruptInexist
        let ?ta = "\<lbrace>ThreadExists (addr2thread_id a) True, WakeUp (addr2thread_id a), Interrupt (addr2thread_id a), ObsInterrupt (addr2thread_id a)\<rbrace>"
        from RedInterruptInexist None False
        have "\<not> free_thread_id (thr s) (addr2thread_id a)" by(auto simp add: wset_actions_ok_def)
        hence "final_thread.actions_ok final s t ?ta" using None 
          by(auto simp add: final_thread.actions_ok_iff final_thread.cond_action_oks.simps wset_actions_ok_def)
        moreover obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta\<rightarrow>ext \<langle>va,h'\<rangle>" using RedInterruptInexist RedInterrupt by auto
        ultimately show ?thesis by blast
      next
        case (RedIsInterruptedTrue C)
        let ?ta' = "\<lbrace>IsInterrupted ?t_a False\<rbrace>"
        from RedIsInterruptedTrue False None have "?t_a \<notin> interrupts s" by(auto)
        hence "final_thread.actions_ok' s t ?ta'" using None by auto
        moreover from RedIsInterruptedTrue have "final_thread.actions_subset ?ta' ta" by auto
        moreover from RedIsInterruptedTrue RedIsInterruptedFalse obtain va h'
          where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by auto
        ultimately show ?thesis by blast
      next
        case (RedIsInterruptedFalse C)
        let ?ta' = "\<lbrace>IsInterrupted ?t_a True, ObsInterrupted ?t_a\<rbrace>"
        from RedIsInterruptedFalse have "?t_a \<in> interrupts s"
          using False None by(auto simp add: interrupt_actions_ok'_def)
        hence "final_thread.actions_ok final s t ?ta'"
          using None by(auto simp add: final_thread.actions_ok_iff final_thread.cond_action_oks.simps)
        moreover obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>"
          using RedIsInterruptedFalse RedIsInterruptedTrue by auto
        ultimately show ?thesis by blast
      next
        case RedWaitInterrupt
        note ta = `ta = \<lbrace>Unlock\<rightarrow>a, Lock\<rightarrow>a, IsInterrupted t True, ClearInterrupt t, ObsInterrupted t\<rbrace>`
        from ta False None have hli: "\<not> has_lock ((locks s)\<^sub>f a) t \<or> t \<notin> interrupts s"
          by(fastforce simp add: lock_actions_ok'_iff finfun_upd_apply split: split_if_asm dest: may_lock_t_may_lock_unlock_lock_t dest: has_lock_may_lock)
        show ?thesis
        proof(cases "has_lock ((locks s)\<^sub>f a) t")
          case True
          let ?ta' = "\<lbrace>Suspend a, Unlock\<rightarrow>a, Lock\<rightarrow>a, ReleaseAcquire\<rightarrow>a, IsInterrupted t False, SyncUnlock a \<rbrace>"
          from True hli have "t \<notin> interrupts s" by simp
          with True False have "final_thread.actions_ok' s t ?ta'" using None
            by(auto simp add: lock_actions_ok'_iff finfun_upd_apply wset_actions_ok_def Cons_eq_append_conv)
          moreover from ta have "final_thread.actions_subset ?ta' ta"
	    by(auto simp add: collect_locks'_def finfun_upd_apply)
          moreover from RedWait RedWaitInterrupt obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by auto
          ultimately show ?thesis by blast
        next
          case False
          let ?ta' = "\<lbrace>UnlockFail\<rightarrow>a\<rbrace>"
          from False have "final_thread.actions_ok' s t ?ta'" using None
            by(auto simp add: lock_actions_ok'_iff finfun_upd_apply)
          moreover from ta have "final_thread.actions_subset ?ta' ta"
	    by(auto simp add: collect_locks'_def finfun_upd_apply)
          moreover from RedWaitInterrupt obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by(fastforce)
          ultimately show ?thesis by blast
        qed
      next
        case RedWait
        note ta = `ta = \<lbrace>Suspend a, Unlock\<rightarrow>a, Lock\<rightarrow>a, ReleaseAcquire\<rightarrow>a, IsInterrupted t False, SyncUnlock a\<rbrace>`

        from ta False None have hli: "\<not> has_lock ((locks s)\<^sub>f a) t \<or> t \<in> interrupts s"
          by(auto simp add: lock_actions_ok'_iff finfun_upd_apply wset_actions_ok_def Cons_eq_append_conv split: split_if_asm dest: may_lock_t_may_lock_unlock_lock_t dest: has_lock_may_lock)
        show ?thesis
        proof(cases "has_lock ((locks s)\<^sub>f a) t")
          case True
          let ?ta' = "\<lbrace>Unlock\<rightarrow>a, Lock\<rightarrow>a, IsInterrupted t True, ClearInterrupt t, ObsInterrupted t\<rbrace>"
          from True hli have "t \<in> interrupts s" by simp
          with True False have "final_thread.actions_ok final s t ?ta'" using None
            by(auto simp add: final_thread.actions_ok_iff final_thread.cond_action_oks.simps lock_ok_las_def finfun_upd_apply has_lock_may_lock)
          moreover from RedWait RedWaitInterrupt obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by auto
          ultimately show ?thesis by blast
        next
          case False
          let ?ta' = "\<lbrace>UnlockFail\<rightarrow>a\<rbrace>"
          from False have "final_thread.actions_ok' s t ?ta'" using None
            by(auto simp add: lock_actions_ok'_iff finfun_upd_apply)
          moreover from ta have "final_thread.actions_subset ?ta' ta"
	    by(auto simp add: collect_locks'_def finfun_upd_apply)
          moreover from RedWait RedWaitFail obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by(fastforce)
          ultimately show ?thesis by blast
        qed
      next
        case RedWaitFail
        note ta = `ta = \<lbrace>UnlockFail\<rightarrow>a\<rbrace>`
        let ?ta' = "if t \<in> interrupts s
                   then \<lbrace>Unlock\<rightarrow>a, Lock\<rightarrow>a, IsInterrupted t True, ClearInterrupt t, ObsInterrupted t\<rbrace>
                   else \<lbrace>Suspend a, Unlock\<rightarrow>a, Lock\<rightarrow>a, ReleaseAcquire\<rightarrow>a, IsInterrupted t False, SyncUnlock a \<rbrace>"
        from ta False None have "has_lock ((locks s)\<^sub>f a) t"
          by(auto simp add: finfun_upd_apply split: split_if_asm)
        hence "final_thread.actions_ok final s t ?ta'" using None
          by(auto simp add: final_thread.actions_ok_iff final_thread.cond_action_oks.simps lock_ok_las_def finfun_upd_apply has_lock_may_lock wset_actions_ok_def)
        moreover from RedWaitFail RedWait RedWaitInterrupt
        obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>"
          by(cases "t \<in> interrupts s") (auto)
        ultimately show ?thesis by blast
      next
        case RedWaitNotified
        note ta = `ta = \<lbrace>Notified\<rbrace>`
        let ?ta' = "if has_lock ((locks s)\<^sub>f a) t
                   then (if t \<in> interrupts s 
                         then \<lbrace>Unlock\<rightarrow>a, Lock\<rightarrow>a, IsInterrupted t True, ClearInterrupt t, ObsInterrupted t\<rbrace>
                         else \<lbrace>Suspend a, Unlock\<rightarrow>a, Lock\<rightarrow>a, ReleaseAcquire\<rightarrow>a, IsInterrupted t False, SyncUnlock a \<rbrace>)
                   else \<lbrace>UnlockFail\<rightarrow>a\<rbrace>"
        have "final_thread.actions_ok final s t ?ta'" using None
          by(auto simp add: final_thread.actions_ok_iff final_thread.cond_action_oks.simps lock_ok_las_def finfun_upd_apply has_lock_may_lock wset_actions_ok_def)
        moreover from RedWaitNotified RedWait RedWaitInterrupt RedWaitFail
        have "\<exists>va h'. P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by auto
        ultimately show ?thesis by blast
      next
        case RedWaitInterrupted
        note ta = `ta = \<lbrace>WokenUp, ClearInterrupt t, ObsInterrupted t\<rbrace>`
        let ?ta' = "if has_lock ((locks s)\<^sub>f a) t
                   then (if t \<in> interrupts s 
                         then \<lbrace>Unlock\<rightarrow>a, Lock\<rightarrow>a, IsInterrupted t True, ClearInterrupt t, ObsInterrupted t\<rbrace>
                         else \<lbrace>Suspend a, Unlock\<rightarrow>a, Lock\<rightarrow>a, ReleaseAcquire\<rightarrow>a, IsInterrupted t False, SyncUnlock a \<rbrace>)
                   else \<lbrace>UnlockFail\<rightarrow>a\<rbrace>"
        have "final_thread.actions_ok final s t ?ta'" using None
          by(auto simp add: final_thread.actions_ok_iff final_thread.cond_action_oks.simps lock_ok_las_def finfun_upd_apply has_lock_may_lock wset_actions_ok_def)
        moreover from RedWaitInterrupted RedWait RedWaitInterrupt RedWaitFail
        have "\<exists>va h'. P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by auto
        ultimately show ?thesis by blast
      next
        case RedNotify
        note ta = `ta = \<lbrace>Notify a, Unlock\<rightarrow>a, Lock\<rightarrow>a\<rbrace>`
        let ?ta' = "\<lbrace>UnlockFail\<rightarrow>a\<rbrace>"
        from ta False None have "\<not> has_lock ((locks s)\<^sub>f a) t"
	  by(fastforce simp add: lock_actions_ok'_iff finfun_upd_apply wset_actions_ok_def Cons_eq_append_conv split: split_if_asm dest: may_lock_t_may_lock_unlock_lock_t has_lock_may_lock)
        hence "final_thread.actions_ok' s t ?ta'" using None
          by(auto simp add: lock_actions_ok'_iff finfun_upd_apply)
        moreover from ta have "final_thread.actions_subset ?ta' ta"
	  by(auto simp add: collect_locks'_def finfun_upd_apply)
        moreover from RedNotify obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by(fastforce)
        ultimately show ?thesis by blast
      next
        case RedNotifyFail
        note ta = `ta = \<lbrace>UnlockFail\<rightarrow>a\<rbrace>`
        let ?ta' = "\<lbrace>Notify a, Unlock\<rightarrow>a, Lock\<rightarrow>a\<rbrace>"
        from ta False None have "has_lock ((locks s)\<^sub>f a) t"
          by(auto simp add: finfun_upd_apply split: split_if_asm)
        hence "final_thread.actions_ok' s t ?ta'" using None
          by(auto simp add: finfun_upd_apply simp add: wset_actions_ok_def intro: has_lock_may_lock)
        moreover from ta have "final_thread.actions_subset ?ta' ta"
	  by(auto simp add: collect_locks'_def finfun_upd_apply)
        moreover from RedNotifyFail obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by(fastforce)
        ultimately show ?thesis by blast
      next
        case RedNotifyAll
        note ta = `ta = \<lbrace>NotifyAll a, Unlock\<rightarrow>a, Lock\<rightarrow>a\<rbrace>`
        let ?ta' = "\<lbrace>UnlockFail\<rightarrow>a\<rbrace>"
        from ta False None have "\<not> has_lock ((locks s)\<^sub>f a) t"
	  by(auto simp add: lock_actions_ok'_iff finfun_upd_apply wset_actions_ok_def Cons_eq_append_conv split: split_if_asm dest: may_lock_t_may_lock_unlock_lock_t)
        hence "final_thread.actions_ok' s t ?ta'" using None
          by(auto simp add: lock_actions_ok'_iff finfun_upd_apply)
        moreover from ta have "final_thread.actions_subset ?ta' ta"
	  by(auto simp add: collect_locks'_def finfun_upd_apply)
        moreover from RedNotifyAll obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by(fastforce)
        ultimately show ?thesis by blast
      next
        case RedNotifyAllFail
        note ta = `ta = \<lbrace>UnlockFail\<rightarrow>a\<rbrace>`
        let ?ta' = "\<lbrace>NotifyAll a, Unlock\<rightarrow>a, Lock\<rightarrow>a\<rbrace>"
        from ta False None have "has_lock ((locks s)\<^sub>f a) t"
          by(auto simp add: finfun_upd_apply split: split_if_asm)
        hence "final_thread.actions_ok' s t ?ta'" using None
          by(auto simp add: finfun_upd_apply wset_actions_ok_def intro: has_lock_may_lock)
        moreover from ta have "final_thread.actions_subset ?ta' ta"
	  by(auto simp add: collect_locks'_def finfun_upd_apply)
        moreover from RedNotifyAllFail obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>" by(fastforce)
        ultimately show ?thesis by blast
      next
        case RedInterruptedTrue
        let ?ta' = "\<lbrace>IsInterrupted t False\<rbrace>"
        from RedInterruptedTrue have "final_thread.actions_ok final s t ?ta'"
          using None False by(auto simp add: final_thread.actions_ok_iff final_thread.cond_action_oks.simps)
        moreover obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>"
          using RedInterruptedFalse RedInterruptedTrue by auto
        ultimately show ?thesis by blast
      next
        case RedInterruptedFalse
        let ?ta' = "\<lbrace>IsInterrupted t True, ClearInterrupt t, ObsInterrupted t\<rbrace>"
        from RedInterruptedFalse have "final_thread.actions_ok final s t ?ta'"
          using None False
          by(auto simp add: final_thread.actions_ok_iff final_thread.cond_action_oks.simps interrupt_actions_ok'_def)
        moreover obtain va h' where "P,t \<turnstile> \<langle>a\<bullet>M(vs),h\<rangle> -?ta'\<rightarrow>ext \<langle>va,h'\<rangle>"
          using RedInterruptedFalse RedInterruptedTrue by auto
        ultimately show ?thesis by blast
      qed(auto simp add: None)
    qed
  qed
qed

end

context heap_base begin

lemma red_external_ta_satisfiable:
  fixes final
  assumes "P,t \<turnstile> \<langle>a\<bullet>M(vs), h\<rangle> -ta\<rightarrow>ext \<langle>va, h'\<rangle>"
  shows "\<exists>s. final_thread.actions_ok final s t ta"
proof -
  note [simp] = 
    final_thread.actions_ok_iff final_thread.cond_action_oks.simps final_thread.cond_action_ok.simps
    lock_ok_las_def finfun_upd_apply wset_actions_ok_def has_lock_may_lock
    and [intro] =
    free_thread_id.intros
    and [cong] = conj_cong
  
  from assms show ?thesis by cases(fastforce intro: exI[where x="(\<lambda>\<^isup>f None)(\<^sup>f a := \<lfloor>(t, 0)\<rfloor>)"] exI[where x="(\<lambda>\<^isup>f None)"])+
qed

lemma red_external_aggr_ta_satisfiable:
  fixes final
  assumes red: "(ta, va, h') \<in> red_external_aggr P t a M vs h"
  and native: "is_native P (the (typeof_addr h a)) M"
  shows "\<exists>s. final_thread.actions_ok final s t ta"
proof -
  note [simp] = 
    final_thread.actions_ok_iff final_thread.cond_action_oks.simps final_thread.cond_action_ok.simps
    lock_ok_las_def finfun_upd_apply wset_actions_ok_def has_lock_may_lock
    and [intro] =
    free_thread_id.intros
    and [cong] = conj_cong
  
  from red native show ?thesis
    by(fastforce simp add: red_external_aggr_def is_native_def2 native_call_def split_beta ta_upd_simps elim!: external_WT_defs_cases elim: external_WT_defs.cases split: split_if_asm intro: exI[where x="(\<lambda>\<^isup>f None)(\<^sup>f a := \<lfloor>(t, 0)\<rfloor>)"] exI[where x="(\<lambda>\<^isup>f None)"])
qed

end

subsection {* Determinism *}

context heap_base begin

lemma heap_copy_loc_deterministic:
  assumes det: "deterministic_heap_ops"
  and copy: "heap_copy_loc a a' al h ops h'" "heap_copy_loc a a' al h ops' h''"
  shows "ops = ops' \<and> h' = h''"
using copy
by(auto elim!: heap_copy_loc.cases dest: deterministic_heap_ops_readD[OF det] deterministic_heap_ops_writeD[OF det])

lemma heap_copies_deterministic:
  assumes det: "deterministic_heap_ops"
  and copy: "heap_copies a a' als h ops h'" "heap_copies a a' als h ops' h''"
  shows "ops = ops' \<and> h' = h''"
using copy
apply(induct arbitrary: ops' h'')
 apply(fastforce elim!: heap_copies_cases)
apply(erule heap_copies_cases)
apply clarify
apply(drule (1) heap_copy_loc_deterministic[OF det])
apply clarify
apply(unfold same_append_eq)
apply blast
done

lemma heap_clone_deterministic:
  assumes det: "deterministic_heap_ops"
  and clone: "heap_clone P h a h' obs" "heap_clone P h a h'' obs'"
  shows "h' = h'' \<and> obs = obs'"
using clone
by(fastforce elim!: heap_clone.cases dest: heap_copies_deterministic[OF det] has_fields_fun)

lemma red_external_deterministic:
  fixes final
  assumes det: "deterministic_heap_ops"
  and red: "P,t \<turnstile> \<langle>a\<bullet>M(vs), (shr s)\<rangle> -ta\<rightarrow>ext \<langle>va, h'\<rangle>" "P,t \<turnstile> \<langle>a\<bullet>M(vs), (shr s)\<rangle> -ta'\<rightarrow>ext \<langle>va', h''\<rangle>"
  and aok: "final_thread.actions_ok final s t ta" "final_thread.actions_ok final s t ta'"
  shows "ta = ta' \<and> va = va' \<and> h' = h''"
using red aok
apply(simp add: final_thread.actions_ok_iff lock_ok_las_def)
apply(erule red_external.cases)
apply(erule_tac [!] red_external.cases)
apply simp_all
apply(auto simp add: finfun_upd_apply wset_actions_ok_def dest: heap_clone_deterministic[OF det] split: split_if_asm)
done

end

end