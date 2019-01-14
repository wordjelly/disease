class Oxford::Neurology < Oxford::Oxford
	EXCLUSIONS = ["part","chapter","introduction","treatment","investigations","history","diagnosis","management","causes","pathophysiology","clinical","assessment","features","imaging","epidemiology","diagnostic","procedures","overview","background","complications","anatomy","physiology","indications","contraindications","terminology","symptoms"]

	def topics
		["P E C FD","Extend digits","Neuroanatomical figures","Dermatomes of the upper and lower limbs","Innervation of the upper limbs","Innervation of the lower limbs","Delirium","Loss of consciousness","Acute vertigo","Acute neuromuscular weakness","Acute focal neurological syndromes","Spastic paraparesis","Ataxia","Acute visual failure","Coma","Coma prognosis","Brain death","Excessive daytime sleepiness","Tremor","Tics","Chorea and athetosis","Myoclonus","Dystonia","HTLV","type","Abetalipoproteinemia","Acquired polyneuropathies","Hereditary neuropathies","Mononeuropathies","Disorders of neuromuscular junction: myasthenia gravis","Botulism","Dermatomyositis and polymyositis","Inclusion body myositis","Inherited myopathies","Motor neuron disease","Muscle and nerve pathology","chromosome","gene on chromosome","SMA type","Onset usually age","Ischemic stroke","Prevention of ischemic stroke","Cerebral venous thrombosis","Cerebral aneurysms","Women and epilepsy","Status epilepticus","before and","Migraine therapy","Migraine prophylaxis","Migraine and women","Trigeminal neuralgia","Parkinsonian syndromes associated with dementia","Vascular dementia","Frontotemporal dementia","Other dementias","Normal PrP coded by gene on chromosome","Most common point mutation at codon","Point mutation codon","Hypokinetic movement disorders","Hyperkinetic movement disorders","Huntington disease","Sydenham chorea","Essential tremor","Dystonias","Hereditary ataxias","Sporadic ataxias","Acquired ataxias","Mutation in gene for GTP cyclohydrolase","Onset of tics before age","Chr","SCA","Approach to the patient with a sleep disorder","Classification of sleep disorders","Insomnias","Hypersomnias not due to breathing disorders","Parasomnias","Circadian rhythm sleep disorders","Infectious disease: bacterial meningitis","Bacterial infections and toxins","Viral meningoencephalitis","Highlight on West Nile virus","Neurological disorders due to HIV","Fungal infections","Parasitic infections","Prion diseases","Neurosarcoidosis","between months","sulphadiazine","Classification of intracranial tumors","Paraneoplastic syndromes","ANNA","Cranial trauma","Spinal trauma","Degenerative spinal conditions: cervical spine","Degenerative spinal conditions: thoracic and lumbar spine","Developmental abnormalities","Syringomyelia","Hydrocephalus","EEG: use and abuse","EEG: normal rhythms and benign variants","EEG: abnormal rhythms","EEG and epilepsy","EEG and diffuse cerebral dysfunction","EEG and drug effects","EEG in the intensive care unit","Peripheral nerve disorders: NCS abnormalities","Normal needle EMG","Needle EMG: patterns of abnormality","NCS and needle EMG findings in neuropathies","NCS and needle EMG findings in plexopathies","NCS and needle EMG findings in radiculopathies","NCS and needle EMG findings in myopathies","disorders","Minimum of"]
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