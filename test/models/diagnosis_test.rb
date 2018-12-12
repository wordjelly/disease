require 'test_helper'

class DiagnosisTest < ActiveSupport::TestCase
   

=begin
    test "calculates word positions correctly" do
   		text = """

Symptoms

Signs

1. History: Previous eye surgery?
2. Slit-lamp examination with fluorescein staining: Look for an adjacent area of elevation.

Signs

4.25

injection), increased IOP, and progressive corneal thinning. Treatment is maintained until
the epithelial defect over the ulcer heals and is
then gradually tapered. As long as an epithelial defect is present, there is risk of progressive
thinning and perforation.

Critical. Slowly progressive irregular astigmatism resulting from paracentral thinning and
bulging of the cornea (maximal thinning near
the apex of the protrusion), vertical tension lines
in the posterior cornea (Vogt striae), an irregular
corneal retinoscopic reflex (scissor reflex), and
egg-shaped mires on keratometry. Inferior steepening is seen on corneal topographic evaluation.
Usually bilateral but often asymmetric.

21/12/11 11:59 PM

4.25

•

Keratoconus

99

 Keratoglobus: Rare, congenital, nonpro-

gressive. Uniform circularly thinned cornea
with maximal thinning in the mid-periphery of the cornea. The cornea protrudes
central to the area of maximal thinning.
NOTE: Treatment for pellucid marginal degeneration is the same as for keratoconus, except
corneal transplantation is technically more difficult due to peripheral thinning and has a higher
failure rate because larger grafts are necessary.

FIGURE 4.25.1. Keratoconus.

Other. Fleischer ring (epithelial iron deposits at the base of the cone), bulging of the
lower eyelid when looking downward (Munson sign), superficial corneal scarring. Corneal hydrops (sudden development of corneal
edema) results from a rupture in Descemet
membrane (see Figure 4.25.2).

Associations
Keratoconus is associated with Down syndrome, atopic disease, Turner syndrome, Leber
congenital amaurosis, mitral valve prolapse,
retinitis pigmentosa, and Marfan syndrome. It
is related to chronic eye rubbing. Family history of keratoconus is also a risk factor.

Differential Diagnosis
 Pellucid marginal degeneration: Corneal

thinning in the inferior periphery, 1 to 2
mm from the limbus. The cornea protrudes
superior to the band of thinning.

 Postrefractive surgery ectasia: After lamellar

4

refractive surgery such as LASIK, and rarely
surface ablation, a condition very similar to
keratoconus can develop. It is treated in the
same manner as keratoconus.

Work-Up
1. History: Duration and rate of decreased
vision? Frequent change in eyeglass prescriptions? History of eye rubbing? Medical
problems? Allergies? Family history? Previous refractive surgery?
2. Slit-lamp examination with close attention
to location and characteristics of corneal
thinning, Vogt striae, and a Fleischer ring
(may be best appreciated with cobalt blue
light).
3. Retinoscopy and refraction. Look for irregular astigmatism and a waterdrop or scissors red reflex.
4. Corneal topography (can show central and
inferior steepening) and keratometry (irregular mires and steepening).

Treatment
1. Patients are instructed not to rub their eyes.
2. Correct refractive errors with glasses or soft
contact lenses (for mild cases) or RGP contact lenses (successful in most cases). Occasionally, hybrid contact lenses are required.
3. Partial thickness or full-thickness corneal
transplantation surgery is usually indicated
when contact lenses cannot be tolerated or
no longer produce satisfactory vision.

FIGURE 4.25.2.

Acute corneal hydrops.

LWBK1000-C04_p55-109.indd 99

4. Intracorneal ring segments have been successful in getting some patients back into

21/12/11 11:59 PM

100

C H AP T E R

4•

Cornea

contact lenses, especially in mild-to-moderate keratoconus.

4

5. Corneal collagen cross-linking: A surgical procedure where typically a large corneal epithelial defect is created, riboflavin
drops are placed on the cornea for 30 minutes and then ultraviolet light is shined
on the cornea for another 30 minutes.
The goal is to “cross-link” collagen bonds
in the cornea to strengthen it and slow
down (ideally eliminate) the progression
of keratoconus. It is not currently FDA
approved.
6. Acute corneal hydrops:
—Cycloplegic agent (e.g., cyclopentolate
1%), bacitracin ointment q.i.d., and consider brimonidine 0.1% b.i.d. to t.i.d.

4.26

—Start sodium chloride 5% ointment b.i.d.
until resolved (usually several weeks to
months).
—Glasses or a shield should be worn by
patients at risk for trauma or by those who
rub their eyes.
NOTE: Acute hydrops is not an indication for
emergency corneal transplantation, except in
the extremely rare case of corneal perforation
(which is first treated medically and sometimes
with tissue adhesives).

Follow-Up
Every 3 to 12 months, depending on the progression of symptoms. After an episode of
hydrops, examine the patient every 1 to 4 weeks
until resolved (which can take several months).


"""

		information_objects = Information.derive_information(text)
		puts information_objects["Retinoscopy"].to_json

    end
=end


    test "derives all phrases correctly" do 
    	#puts " --------- PARSING TEXTBOOK ---------- "
    	#Diagnosis.parse_textbook
    	#puts " --------- building information ---------- "
    	#Diagnosis.parse_diagnosis_data
    	#puts " --------- building entities -------------- "
    	#Diagnosis.get_terms
    	#puts " --------- alloting diagnosis ------------- "
    	Diagnosis.allot_to_diagnosis
    end	

=begin

    test "finds closest phrase correctly" do 

    end
=end

end
