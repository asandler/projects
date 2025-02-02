require "rspotify"
require "json"
require "cgi"

# insert info from https://developer.spotify.com/dashboard here
@client_id = "<client_id>"
@client_secret = "<client_secret>"

@user_id = "<spotify_user_id>"

def auth_url
    redirect_uri = "http://localhost:3000"
    state = "abcdefghijklmnop".chars.shuffle.join
    scope = "playlist-modify-private playlist-modify-public user-library-modify"

    url = "https://accounts.spotify.com/authorize"
    url += "?response_type=token"
    url += "&client_id=" + CGI.escape(@client_id)
    url += "&scope=" + CGI.escape(scope)
    url += "&redirect_uri=" + CGI.escape(redirect_uri)
    url += "&state=" + CGI.escape(state)

    return url
end

if !RSpotify::authenticate(@client_id, @client_secret)
    p "Auth failed"
    return
end

puts auth_url

puts "Paste URL from browser here:"
callback_url = gets.chomp
access_token = callback_url.split("#")[1].split("&").keep_if{|s| s.index("access_token=")}[0].split("=")[1]

spotify_user = RSpotify::User.new({
    "credentials" => {
       "token" => access_token,
    },
    "id" => @user_id
})

spotify_user.playlists.each do |pl|
    puts "#{pl.id} #{pl.name}"
end

#### Playlist1.json ####

data = File.open("Playlist1.json"){|f| JSON.load(f)}

data["playlists"].each do |pl_data|
    pl = spotify_user.create_playlist!(pl_data["name"])
    puts "Created playlist: #{pl}"

    pl_data["items"].each_with_index do |item, idx|
        uri = item["track"]["trackUri"].split(":")[2]
        track = RSpotify::Track.find(uri)
        pl.add_tracks!([track])
        puts "#{idx+1}: Added track #{item["track"]["artistName"]} - #{item["track"]["trackName"]}"
    end
end

#### YourLibrary.json ####

puts "Enter playlist id to import your favorite tracks to:"

playlist_id = gets.chomp
p = RSpotify::Playlist.find_by_id(playlist_id)

data = File.open("YourLibrary.json"){|f| JSON.load(f)}

data["tracks"].each_with_index do |t, idx|
    uri = t["uri"].split(":")[2]
    track = RSpotify::Track.find(uri)
    p.add_tracks!([track])
    puts "#{idx+1}: Added track #{t['artist']} - #{t['track']}"
end

data["albums"].each_with_index do |a, idx|
    uri = a["uri"].split(":")[2]
    album = RSpotify::Album.find(uri)
    spotify_user.save_albums!([album])
    puts "#{idx+1}: Added album #{a['artist']} - #{a['album']}"
end
