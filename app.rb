require 'bundler/setup'
Bundler.require(:default)

require 'musicbrainz'
require 'lastfm'

MusicBrainz.configure do |c|
  # Application identity (required)
  c.app_name = "BRAINZZZZ"
  c.app_version = "1.0"
  c.contact = "support@mymusicapp.com"
end


get '/' do
  erb :index
end

post '/' do
  @api_key = ENV['SOUNDCLOUD_KEY']
  @api_id = ENV['SOUNDCLOUD_ID']
  artist = params[:artist]
  @result = MusicBrainz::Artist.find_by_name(artist)
  if @result ==nil
    redirect '/'
  else
    @artist_id = @result.id
  end

  artist_1_url  = "http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&mbid=#{@artist_id}&api_key=#{@api_key}&format=json"
  @artist_1 = HTTParty.get(artist_1_url)

  artist_1_top_tracks_url  = "http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&mbid=#{@artist_id}&api_key=#{@api_key}&format=json"
  @artist_1_top_tracks  = HTTParty.get(artist_1_top_tracks_url)

  artist_1_albums_url  = "http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&mbid=#{@artist_id}&api_key=#{@api_key}&format=json"
  @artist_1_albums  = HTTParty.get(artist_1_albums_url)

  client = Soundcloud.new(:client_id => @api_id)

  clean_artist_name = artist.split(' ').join('').downcase
  # get a tracks oembed data
  track_url = "http://soundcloud.com/#{clean_artist_name}"
  @embed_info = client.get('/oembed', :url => track_url)
  @embed_player_html = @embed_info["html"]

  events_url = "http://ws.audioscrobbler.com/2.0/?method=artist.getevents&mbid=#{@artist_id}&api_key=#{@api_key}&format=json"
  @events  = HTTParty.get(events_url)



  erb :artist
end





      # lastfm = Lastfm.new(api_key, api_secret)
      # token = lastfm.auth.get_token

      # # open 'http://www.last.fm/api/auth/?api_key=xxxxxxxxxxx&token=xxxxxxxx' and grant the application

      # lastfm.session = lastfm.auth.get_session(:token => token)['key']