class Oxford::Dermatology < Oxford::Oxford

	def add_topics(s)
		titles = []
		s.split(/\r|\n|\t/).each do |line|
			line.scan(/^(?<title>[A-Za-z\s\:]+)\s\d+$/) do |title|
				titles << title[0] unless exclude? title[0]
			end
		end
		titles
	end

=begin
	def self.get_dermatology_contents(allergy_book_file_path_and_name,contents_file_path_and_name)
		titles = []
		## first manage the character conversion to utf 8.
		s = IO.read(allergy_book_file_path_and_name)
		s.force_encoding('UTF-8')
		s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
		s.split(/\r|\n|\t/).each do |line|
			
			line.scan(/^(?<title>[A-Za-z\s\:]+)\s\d+$/) do |title|
				
				titles << title
			end
		end
		titles = titles.flatten.uniq.compact.map{|c| c.gsub(/\d+/,'').strip}
		puts titles.size
		IO.write(contents_file_path_and_name,JSON.generate(titles))
	end

	def topics
		["Epidermis","Differentiation and the skin barrier","Dermis and glands","Hair and nails","Melanocytes and colour","Skin immune system","Genetic variation in the amino acid sequence of the melanocortin","History in patients with allergy","History in patients with hair loss","History in patients with skin tumours","History in photosensitivity","Why the skin condition has not responded to treatment","Assessing the impact of skin conditions","Skin and the psyche","The dermatological history:","The dermatological history:","Preparation","Rashes","Skin tumours","Scalp and hair","Nails","Mucosal surfaces","Assessing the severity of a rash","Epidemiology of skin disease","Reaching the diagnosis","Generalized rash in a sick patient","Itch","Linear patterns and sharp demarcations","Scaly or hyperkeratotic red rashes","Smooth erythematous rashes","Purpura and telangiectasia","Red faces","Red legs and leg ulcers","Flexural rashes","Pustules","Blisters","Nodules and solitary cutaneous ulcers","Induration","Change in skin colour","Skin of colour","Hair: too much or too little","Funny nails","Rash in a sick adult with a fever","Vasculitis and purpura fulminans","Skin failure","Erythroderma","Localized blisters","Generalized blisters","Severe cutaneous adverse reactions","necrolysis","or toxic epidermal necrolysis","Generalized pustules","Necrotizing fasciitis","Flexural bacterial infections","Folliculitis and furunculosis","Erysipelas and cellulitis","Erysipeloid","Bacillary angiomatosis","Meningococcal infections","Mycobacterial infections","Syphilis","Lyme disease","Viral exanthems","Pityriasis rosea","Herpes simplex virus","Human papillomavirus","Candida albicans","Scabies","Management of scabies","Lice","Demodicosis and other mites","Fleas and bugs","Cutaneous larva migrans","Cutaneous leishmaniasis","The history in psoriasis","Common clinical patterns","Nails in psoriasis","Erythrodermic and pustular psoriasis","Assessing severity","Approach to management","Topical treatments","Psoriatic arthritis","Reactive arthritis","Contact dermatitis","Atopic eczema and seborrhoeic dermatitis in adults","Other common types of eczema","Chronic scratching and rubbing","Lichen planus","Urticaria","Physical urticaria","Management of urticaria","Erythema annulare centrifugum","Acne: presentation","Acne caused by drugs","Acne vulgaris: management","Acne with arthritis","Follicular occlusion diseases: signs","Follicular occlusion diseases: management","Rosacea","Introduction to blisters","Adhesion in the epidermis","Primary bullous diseases","The approach to the patient","Pemphigus","Bullous pemphigoid","Rare subepidermal blistering diseases","Dermatitis herpetiformis","Oral and genital ulcers","Behet disease","Mucosal lichen planus","Lichen sclerosus","The history","Preparing to examine the ulcer","The examination","Assessing peripheral circulation","Investigation of leg ulcers","Pain and leg ulcers","Management of ulcers","Pyoderma gangrenosum","Calcific uraemic arteriolopathy","Livedoid vasculopathy","Lymphoedema","Lipoedema","Skin phototype and photosensitivity","Causes of photosensitivity","Polymorphic light eruption","Porphyria","Porphyria cutanea tarda","Erythropoietic protoporphyria","Xeroderma pigmentosum","Photoprotection","Common benign melanocytic tumours","Avoiding skin cancer","Premalignant epidermal lesions","Malignant melanoma","Management of melanoma","Other malignancies and skin","reactions","Clinical approach","Generally smooth erythematous drug reactions","More scaly erythematous drug reactions and pruritus","Purpuric or pigmented drug reactions","Drugs and skin diseases","Reactions to chemotherapy agents:","Re actions to chemotherapy agents:","Rheumatoid arthritis","Lupus erythematosus","Assessment of skin in systemic lupus erythematosus","Acute and subacute cutaneous lupus erythematosus","Chronic cutaneous lupus erythematosus","Management of cutaneous lupus erythematosus","Dermatomyositis","Dermatomyositis: the signs","Dermatomyositis: investigation and management","Systemic sclerosis","Systemic sclerosis: signs and investigation","Systemic sclerosis: management","Localized scleroderma","Relapsing polychondritis","Multicentric reticulohistiocytosis","EhlersDanlos syndrome","Marfan syndrome","Pseudoxanthoma elasticum","Oedema persists for","Urticarial vasculitis","Cryoglobulinaemic vasculitis and occlusive vasculopathy","Septic cutaneous vasculitis","vasculitis","Erythema nodosum","Uncommon causes of panniculitis","Diabetes mellitus and the skin","Necrobiosis lipoidica","Hyperlipoproteinaemias","Thyroid disorders and the skin","Hirsutism and hypertrichosis","Polycystic ovary syndrome","Management of hirsutism","Male and female pattern hair loss","Other endocrinopathies","Autoimmune polyendocrine syndromes","Vitiligo","Alopecia areata","Multiple endocrine neoplasia type","Polyglandular autoimmune syndrome type","Skin changes in renal disease","Itch in chronic kidney disease","Amyloidosis","Nephrogenic systemic fibrosis","Skin cancer in renal transplant recipients","Fabry disease","Cirrhosis","Inflammatory bowel disease","Cutaneous Crohn disease","Nutritional deficiencies","herpetiformis","Pancreatic disease","Neutrophilic dermatoses","Carcinoid syndrome","Other rare gastrointestinal conditions","Sarcoidosis","Management of cutaneous sarcoidosis","Radiotherapy","Haematological diseases and skin","Hypergammaglobulinaemias","Familial cancer syndromes","Paraneoplastic skin changes","Neuropathic pain and itch","Autonomic and motor dysfunction","Other neurofibromatoses","Tuberous sclerosis complex and skin","Tuberous sclerosis complex and other organs","Epidermal naevus syndromes","Capillary malformations","Other neurocutaneous disorders","Neurofibromatosis type","Neurofibromatosis type","with neurofibromatosis type","Segmental neurofibromatosis","Localized dysaesthesias","Delusions","Eating disorders and skin","Ageing skin","Common conditions in older patients","Dry itchy skin and asteatotic eczema","Skin in pregnancy","Other skin conditions in pregnancy","Safety of treatments in pregnancy","may occur during the first trimesterthe greatest risk is from weeks","Pustules and blisters","Congenital cutaneous lesions","Infantile haemangioma","Other vascular tumours","Vascular malformations","Red scaly skin in neonates and infants","Napkin rashes","Atopic eczema: top tips","Atopic eczema: gaining control","Cutaneous signs in rare syndromes","Physical and sexual abuse","Genetic basis of skin diseases","Mosaicism","The genetic consultation","Inherited epidermolysis bullosa","The ichthyoses","Darier disease and HaileyHailey disease","Palmoplantar keratodermas","Erythrokeratoderma","Ectodermal dysplasias","Incontinentia pigmenti","Keratin","Connexin","Desmoglein","Tools in the clinic","Testing for allergy","Specimens for bacterial or viral culture","Skin scrapes and smears","Skin biopsy in inflammatory conditions","General principles of topical treatment","Moisturizers and soap substitutes","Topical corticosteroids","Occlusion","Systemic drugs in dermatology","Biological drugs in dermatology","Resources","Dermatology textbooks"]
	end
=end

	## here we have only a title processor, we don't go for subsections.
	def title_processor(line)
		section_name = nil
		
		line.strip.scan(/^(?<title>[A-Za-z\s\:]+)$/) do |title|

			applicable_topics = get_topics.select{|c| title[0].strip == c}

			if applicable_topics.size > 0
				return ["on",clear_numbers_newlines_and_excess_spaces(title[0])]
			else
				return ["off",title[0]]
			end
		end
		return ["off",line]
	end
end