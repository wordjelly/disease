require 'test_helper'

class MeshesControllerTest < ActionController::TestCase


  test "runner" do
=begin
    Diagnosis.create_index! force: true
	puts " --------- PARSING TEXTBOOK ---------- "
	Diagnosis.parse_textbook
	puts " --------- building information ---------- "
	Diagnosis.parse_diagnosis_data
	puts " --------- building entities -------------- "
	Diagnosis.get_terms
=end
	puts " --------- alloting diagnosis ------------- "
	Diagnosis.allot_to_diagnosis
  end

end
