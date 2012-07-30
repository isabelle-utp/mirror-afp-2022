theory Majorities
imports Main
begin

section {* Utility Lemmas About Majorities *}

text {*
  Consensus algorithms usually ensure that a majority of processes
  proposes the same value before taking a decision,
  and we provide a few utility lemmas for reasoning about majorities.
*}

text {*
  Any two subsets @{text S} and @{text T} of a finite  set @{text E} such that
  the sum of their cardinalities is larger than the size of @{text E} have a
  non-empty intersection.
*}
lemma abs_majorities_intersect:
    assumes crd: "card E < card S + card T"
        and s: "S \<subseteq> E" and t: "T \<subseteq> E" and e: "finite E"
    shows "S \<inter> T \<noteq> {}"
proof (clarify)
  assume contra: "S \<inter> T = {}"
  from s t e have "finite S" and "finite T" by (auto simp: finite_subset)
  with crd contra have "card E < card (S \<union> T)" by (auto simp add: card_Un_Int)
  moreover
  from s t e have "card (S \<union> T) \<le> card E" by (simp add: card_mono)
  ultimately
  show "False" by simp
qed

lemma abs_majoritiesE:
  assumes crd: "card E < card S + card T"
      and s: "S \<subseteq> E" and t: "T \<subseteq> E" and e: "finite E"
  obtains p where "p \<in> S" and "p \<in> T"
proof -
  from assms have "S \<inter> T \<noteq> {}" by (rule abs_majorities_intersect)
  then obtain p where "p \<in> S \<inter> T" by blast
  with that show ?thesis by auto
qed

text {* Special case: both sets @{text S} and @{text T} are majorities. *}

lemma abs_majoritiesE':
  assumes Smaj: "card S > (card E) div 2" and Tmaj: "card T > (card E) div 2"
      and s: "S \<subseteq> E" and t: "T \<subseteq> E" and e: "finite E"
  obtains p where "p \<in> S" and "p \<in> T"
proof (rule abs_majoritiesE[OF _ s t e])
  from Smaj Tmaj show "card E < card S + card T" by auto
qed

text {*
  We restate the above theorems for the case where the base type
  is finite (taking @{text E} as the universal set).
*}

lemma majorities_intersect:
  assumes crd: "card (UNIV::('a::finite) set) < card (S::'a set) + card T"
  shows "S \<inter> T \<noteq> {}"
  by (rule abs_majorities_intersect[OF crd]) auto

lemma majoritiesE:
  assumes crd: "card (UNIV::('a::finite) set) < card (S::'a set) + card (T::'a set)"
  obtains p where "p \<in> S" and "p \<in> T"
using crd majorities_intersect by blast

lemma majoritiesE':
  assumes S: "card (S::('a::finite) set) > (card (UNIV::'a set)) div 2"
  and T: "card (T::'a set) > (card (UNIV::'a set)) div 2"
  obtains p where "p \<in> S" and "p \<in> T"
by (rule abs_majoritiesE'[OF S T]) auto

end (* theory Majorities *)
