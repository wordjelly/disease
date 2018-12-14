require 'test_helper'

class DiagnosisTest < ActiveSupport::TestCase
    
    setup do
        #Diagnosis.create_index! force: true
        
        #diagnosis_entity_size = Diagnosis.all.size
        #if diagnosis_entity_size == 0
        #    Diagnosis.create_index! force: true
        #    Diagnosis.parse_textbook
        #    Diagnosis.gateway.client.indices.refresh index: Diagnosis.index_name
        #end
       
    end
=begin
    test " ANCA is correctly set " do 

        ["EPISCLERITIS","SCLERITIS"].each do |anca_workup|

            puts "diagnosis --> #{anca_workup}"

            response = Diagnosis.gateway.client.search index: Diagnosis.index_name, body:
            {
                query: {
                    term: {
                        title: anca_workup
                    }
                },
                size: 1
            }

            mash = Hashie::Mash.new response

            #puts mash.hits.hits.first._source.buffer.to_s

            text_to_analyze = mash.hits.hits.first._source.buffer

            information_objects = Information.derive_information(text_to_analyze)

            assert_equal information_objects["ANCA"][0].closest, "WorkUp"

            puts "assert clear -----------------<>"

        end

    end

    test " CANCA is correctly set " do 

        ["LACRIMAL GLAND MASS/CHRONIC DACRYOADENITIS","ORBITAL DISEASE","MISCELLANEOUS ORBITAL DISEASES"].each do |canca_workup|

            response = Diagnosis.gateway.client.search index: Diagnosis.index_name, body:
            {
                query: {
                    term: {
                        title: canca_workup
                    }
                },
                size: 1
            }

            mash = Hashie::Mash.new response

            #puts mash.hits.hits.first._source.buffer.to_s

            text_to_analyze = mash.hits.hits.first._source.buffer

            information_objects = Information.derive_information(text_to_analyze)

            assert_equal information_objects["cANCA"][0].closest, "WorkUp"
            puts "diagnosis --> #{canca_workup} ---> clear"

        end

    end
=end
end
