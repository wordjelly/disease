module MeshBuilder
	def self.read_ascii_bin
		q = IO.read("#{Rails.root}/vendor/MESH_ASCII_2017.bin")
	end
end