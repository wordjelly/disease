class Oxford::Rheumatology < Oxford::Oxford


	EXCLUSIONS = ["introduction","chapter"]


	def topics
		["Evaluating rheumatological and musculoskeletal","symptoms","Musculoskeletal pain in adults","Elicited pain on examination in adults","Other presenting symptoms in adults","The adult gait, arms, legs, spine (GALS) screening examination","Pain assessment in children and adolescents","Limp and gait concerns in children and adolescents","Pyrexia, fatigue and unexplained acute-phase response in children and","adolescents","The paediatric GALS screen","The spectrum of disorders associated with adult","rheumatic and musculoskeletal diseases","Skin disorders and rheumatic disease","Skin vasculitis in adults","Cardiac conditions","Pulmonary conditions","Renal conditions","Endocrine conditions","Gut and hepatobiliary conditions","Malignancy","Neurological conditions","Ophthalmic conditions","Rheumatoid arthritis","Clinical features","Investigations","Management","Osteoarthritis","Epidemiology","Pathology","Aetiology","Investigation","Prognosis","Crystal-induced musculoskeletal disease","Gout and hyperuricaemia","Calcium pyrophosphate deposition disease","Basic calcium phosphate crystal-associated disease","Calcium oxalate arthritis","Juvenile idiopathic arthritis","Management of JIA","Transition services","JIA subtypes and their specific features","Macrophage activation syndrome","Uveitis","Systemic lupus erythematosus","Pathophysiology","Clinical features of systemic lupus erythematosus (SLE)","Antiphospholipid syndrome and SLE","Pregnancy and SLE","Assessment of disease activity","Drug-induced SLE","Management of SLE","Prognosis and survival","Juvenile SLE","Neonatal lupus syndrome","Antiphospholipid syndrome","Catastrophic antiphospholipid syndrome","Systemic sclerosis and related disorders","Introduction and definitions","Epidemiology and pathophysiology of systemic sclerosis (SScl)","Classification of SScl","Approach to diagnosis of SScl","Clinical features of SScl","Treatment and prognosis of SScL","Morphoea, localized scleroderma, and scleroderma-like fibrosing disorders","Idiopathic inflammatory myopathies including","polymyositis and dermatomyositis","Idiopathic inflammatory myositis","Polymyositis and dermatomyositis","Treatment","Inclusion-body myositis","Other (adult) inflammatory myopathies","Juvenile idiopathic inflammatory myopathy","Primary vasculitides","Large vessel vasculitis","Takayasu arteritis","Polymyalgia rheumatica and giant cell arteritis","Polyarteritis nodosa","ANCA-associated vasculitides","Small vessel vasculitis","Childhood-onset vasculitides","Infection and rheumatic disease","Septic arthritis","Mycobacterium tuberculosis","Osteomyelitis","Lyme disease","Rheumatic fever","Spinal disorders and back pain","A categorization of back pain","Acute and subacute back pain (adults)","Chronic back pain (adults)","Back pain in children and adolescents","Chronic pain syndromes","Pain","Generalized pain syndromes","Localized pain syndromes","Chronic pain in children and adolescents","Complex regional pain syndrome in children and adolescents","Drugs used in rheumatology practice","Pain relief","Glucocorticoids","Disease-modifying antirheumatic drugs","Other medications","Glucocorticoid injection therapy","Principles of injection techniques","The shoulder","The elbow","The wrist and hand","The hip and periarticular lesions","The knee and periarticular lesions","The ankle and foot"]
	end


	def self.get_contents(allergy_book_file_path_and_name,contents_file_path_and_name)
		titles = []
		## first manage the character conversion to utf 8.
		s = IO.read(allergy_book_file_path_and_name)
		it = 0
		s.scan(/\[SECTION\]Chapter\s\d+\n(?<chapter_contents>[A-Za-z\s,\(\)\-]+)\n{2}/) do |chapter_contents|
			#puts " ----- chapter contents 0 --- "
			#puts chapter_contents[0].to_s
			chapter_contents[0].split(/\n/).each do |ct|
				puts "ct is: #{ct}"
				unless EXCLUSIONS.include? ct.downcase
					titles << ct
				end
			end
		end
		titles = titles.flatten.uniq.compact.map{|c| c.gsub(/\d+/,'').strip}
		puts titles.size
		IO.write(contents_file_path_and_name,JSON.generate(titles))
	end

	## here we have only a title processor, we don't go for subsections.
	## will first have to remove those sections from the 
	def title_processor(line)

		section_name = nil
		
		line.scan(/^(?<title>[A-Za-z\s,\(\)\-]+)$/) do |title|

			applicable_topics = topics.select{|c| title[0].strip == c}

			if applicable_topics.size > 0

				return ["on",clear_numbers_newlines_and_excess_spaces(title[0])]
			else
				return ["off",title[0]]
			end
		end

		return ["off",line]
	
	end

end	