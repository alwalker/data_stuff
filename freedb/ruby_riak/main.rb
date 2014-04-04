#file name is disc id
# '#' are comments

require 'riak'

client = Riak::Client.new({:host=>'192.168.1.47', :http_port => 10018})

genres = []
artistsalbums = {}

songs_bucket = client.bucket('songs')
genres_bucket = client.bucket('genres')
artists_bucket = client.bucket('artists')
albums_bucket = client.bucket('albums')

def processAlbum(discId, albumArtist, albumTitle, genre, year, tracks)
end

def processFile(file, error_file)
	discId = albumArtist = albumTitle = genre = year = ''
	tracks = []

	puts "opppening #{file}"

	begin
		IO.foreach(file) do |line|
			line = line.strip

			if line.include?("DISCID")
				discId = line.split('DISCID=')[1]
			elsif line.include?('DTITLE') # artist / title
				albumArtist, albumTitle = line.split('DTITLE=')[1].split(' / ')
			elsif line.include?('DGENRE')
				genre = line.split('DGENRE=')[1]
			elsif line.include?('DYEAR=')
				year = line.split('DYEAR=')[1]
			elsif line.include?('TTITLE')
				match = line.match /(.*) \/ (.*)/
				if match
					tracks.push({:title => match[2], :artist => match[1]})
				else
					tracks.push({:title => line.split(/TTITLE\d+=/)[1]})
				end
			end
		end
	rescue
		error_file.write("Couldn't parse #{file}: #{$!}")
	end

	puts "discId: #{discId}\nalbumArtist: #{albumArtist}\nalbumTitle: #{albumTitle}\ngenre: #{genre}\nyear: #{year}\n"
	tracks.each do |track|
		puts "\ttrack: #{track[:title]}\n\tartist: #{track[:artist]}"
	end
end

def processdDirectory(name, count)
	error_file = File.open('errors.txt', 'w')

	Dir.open(name) do |dir|
		dir.each do |file|
			next if file == '.' or file == '..' or file == 'COPYING' or file == 'README'

			newName = name + '/' + file

			if File.directory?(newName)
				processdDirectory(newName, count)
			else
				processFile newName, error_file

				count = count + 1
				if(count >= 20)
					exit
				end
			end
		end
	end

	error_file.close
end


system('clear')
#processdDirectory('/home/alwalker/code')
processdDirectory('/home/alwalker/Downloads/freedb-complete-20140301', 0)
