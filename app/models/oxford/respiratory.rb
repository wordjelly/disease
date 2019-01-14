class Oxford::Respiratory < Oxford::Oxford

	EXCLUSIONS = ["part","chapter","introduction","treatment","investigations","history","diagnosis","management","causes","pathophysiology","clinical","assessment","features","imaging","epidemiology","diagnostic","procedures","overview","background","complications","anatomy","physiology","indications","contraindications","terminology","symptoms"]

	def topics
		["Acute pleuritic chest pain","Chronic chest pain","Diffuse alveolar haemorrhage","p","Transudative pleural effusions","Exudative pleural effusions","Pleural uid analysis","PLEURAL FLUID ANALYSIS","course after transplantation","Asbestos","Asbestosis","Acute severe asthma","Asthma in pregnancy","Occupational asthma","Vocal cord dysfunction","See p","COPD exacerbations","COPD severity according to NICE guidelines","at","Stopped at","Polymyositis and dermatomyositis","Systemic sclerosis","Sjgrens syndrome","Ankylosing spondylitis","Behets syndrome","General principles","CF pulmonary sepsis: aetiology","IV antibiotic administration","Other pulmonary interventions","Other pulmonary disease","Other issues","Seeing the patient with CF in clinic","Gene found on the long arm of chromosome","CF pulmonary sepsis antibiotics:","CF PULMONARY SEPSIS ANTIBIOTICS:","Eosinophilic lung disease","Most common in men aged","Lung disease and ying","Altitude sickness","Diving","Hepatic hydrothorax and hepatopulmonary syndrome","Portopulmonary hypertension","and pancreatitis","often","Staging","NSCLC: chemotherapy","NSCLC: radiotherapy","Lung cancer: emerging areas","Hypercalcaemia","Spinal cord compression","Pulmonary carcinoid tumours","Lung cancer screening","Pulmonary nodules","PULMONARY NODULES","Patient selection","Specic conditions","Mediastinal abnormalities","MEDIASTINAL ABNORMALITIES","Chronic lung disease of prematurity","Viral wheeze and asthma","Congenital abnormalities","outcome","Tuberculous pleural effusion","Silicosis","Berylliosis","Specic situations","Procedure described on p","Classication","future developments","Aetiology","Special circumstances","CAP: antibiotics","Aspiration pneumonia","Nocardiosis","Actinomycosis","Anthrax","Tularaemia","Melioidosis","Leptospirosis","Confusionabbreviated mental test score","Amoxicillin","Those aged over","Aspergillus lung disease: classication","Atopic allergy to fungal spores","Asthma and positive IgG precipitins to Aspergillus","Bronchopulmonary aspergillosis","Invasive aspergillosis","Endemic mycoses","Histoplasmosis","Blastomycosis","Coccidioidomycosis","Paracoccidioidomycosis","Other fungi: cryptococcosis","Candidal pneumonia","TB: pulmonary disease","TB: extrapulmonary disease","TB in pregnancy","TB chemotherapy with comorbid disease","TB: adverse drug reactions","Latent TB infection","TB: screening and contact tracing","age","Pulmonary hydatid disease","Amoebic pulmonary disease","Pulmonary ascariasis","Strongyloidiasis","Toxocariasis","Dirolariasis","Schistosomiasis","Paragonimiasis","Tropical pulmonary eosinophilia","Cytomegalovirus pneumonia","Varicella pneumonia","Respiratory syncytial virus","Measles","Hantavirus pulmonary syndrome","inuenza in the setting of a pandemic with UK Pandemic Alert Level","Aetiology and pathology","Stage","Acute chest syndrome","Sickle cell chronic lung disease","OSA: types of sleep study","OSA: nasal CPAP","OSA: driving advice to patients","OSA in children","OSA: future developments","hypoventilation","Class","Paraquat poisoning","Carbon monoxide poisoning","Inhalational lung injury","INHALATIONAL LUNG INJURY","Alveolar microlithiasis","Hereditary haemorrhagic telangiectasia","Idiopathic pulmonary haemosiderosis","Langerhans cell histiocytosis","Recurrent respiratory papillomatosis","Amyloidosis: lung involvement","AMYLOIDOSIS: LUNG INVOLVEMENT","Acute upper airway obstruction","Anaphylaxis","Upper respiratory tract infections","UPPER RESPIRATORY TRACT INFECTIONS","Microscopic polyangiitis","Goodpastures disease","ChurgStrauss syndrome","Rare pulmonary vasculitides","COPD","Lung cancer and neurological disease","Medical Council","Patient nancial entitlements","Patient advice and monitoring","Corticosteroids and azathioprine","Methotrexate and cyclophosphamide","Different inhaler types and instructions for their use","NIV in acute respiratory failure: practical use","NIV in chronic respiratory failure","Acute oxygen therapy","Home oxygen therapy","Practical issues","Lung cancer and mesothelioma","Aims and patient selection","Programme","Aims and nicotine replacement therapy","Simple airway","Patient preparation and procedure","Sampling techniques","Central airway obstruction","Interventional bronchoscopy","Insertion technique","Skin prick tests","Technique of induced sputum","Methacholine challenge testing","Chemical pleurodesis","Therapeutic thoracentesis","Appendix","Use of Aa gradient diagram: examples","Acidbase balance","APPENDIX","Interpretation of arterial blood gases:","INTERPRETATION OF ARTERIAL BLOOD GASES:","blood gases:","APPENDIX","P","and lung volumes","Peak ow reference ranges","Flowvolume loop","FLOWVOLUME LOOP","Posterior to anterior view","Left lateral view","Lobar collapses","approximately"]
	end


	def self.get_contents(allergy_book_file_path_and_name,contents_file_path_and_name)
		titles = []
		## first manage the character conversion to utf 8.
		s = IO.read(allergy_book_file_path_and_name)
		s.force_encoding('UTF-8')
		s = s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
		s.split(/\r|\n|\t/).each do |line|
			
			line.scan(/^(?<title>[A-Za-z\s\:]+)\s\d+$/) do |title|
				unless EXCLUSIONS.include? title[0].strip.downcase
					unless EXCLUSIONS.select{|c| title[0].strip.downcase =~ /#{c}/i}.size > 0
						titles << title
					end
				end
			end
		end
		titles = titles.flatten.uniq.compact.map{|c| c.gsub(/\d+/,'').strip}
		puts titles.size
		IO.write(contents_file_path_and_name,JSON.generate(titles))
	end

	## here we have only a title processor, we don't go for subsections.
	def title_processor(line)
		section_name = nil
		
		line.strip.scan(/^(?<title>[A-Za-z\s\:]+)$/) do |title|

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