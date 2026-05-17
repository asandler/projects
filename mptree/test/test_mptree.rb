require 'fileutils'
require 'minitest/autorun'
require 'tmpdir'

load File.expand_path('../mptree', __dir__)

class MPTreeTest < Minitest::Test
  def setup
    @options = MPTree.default_options
  end

  def test_build_destination_rejects_missing_artist_or_title
    assert_nil MPTree.build_destination('artist' => '', 'title' => 'Song')
    assert_nil MPTree.build_destination('artist' => 'Artist', 'title' => '')
  end

  def test_build_destination_sanitizes_segments_and_tracks
    tags = {
      'artist' => 'AC/DC',
      'album' => 'Back/In/Black',
      'year' => '1980',
      'track' => '1/10',
      'title' => 'Hells/Bells'
    }

    assert_equal File.join('AC_DC', '1980 - Back_In_Black', '01 - Hells_Bells.mp3'),
                 MPTree.build_destination(tags)
  end

  def test_move_file_skips_existing_destination_without_force
    in_tmpdir do
      File.write('source.mp3', 'source')
      File.write('dest.mp3', 'dest')

      refute MPTree.move_file('source.mp3', 'dest.mp3', @options)
      assert_equal 'source', File.read('source.mp3')
      assert_equal 'dest', File.read('dest.mp3')
    end
  end

  def test_move_file_overwrites_existing_destination_with_force
    @options.force = true

    in_tmpdir do
      File.write('source.mp3', 'source')
      File.write('dest.mp3', 'dest')

      assert MPTree.move_file('source.mp3', 'dest.mp3', @options)
      refute File.exist?('source.mp3')
      assert_equal 'source', File.read('dest.mp3')
    end
  end

  def test_cleanup_removes_empty_directories_only
    in_tmpdir do
      FileUtils.mkdir_p('empty/child')
      FileUtils.mkdir_p('kept')
      File.write('kept/song.mp3', 'content')

      MPTree.cleanup_empty_directories('.', @options)

      refute Dir.exist?('empty')
      assert Dir.exist?('kept')
      assert_equal 'content', File.read('kept/song.mp3')
    end
  end

  def test_plain_song_name_removes_only_leading_track_number
    assert_equal 'Song - Live.mp3',
                 MPTree.plain_song_name('./Artist/Album/03 - Song - Live.mp3')
  end

  def test_parse_arguments_supports_legacy_debug_and_default
    mode, options, status = MPTree.parse_arguments(%w[parse debug default=1])

    assert_equal 0, status
    assert_equal 'parse', mode
    assert options.debug
    assert options.dry_run
    assert_equal '1', options.default_choice
  end

  def test_parse_id3v1_reads_standard_tag
    in_tmpdir do
      File.binwrite('song.mp3', 'audio'.b + id3v1_tag)

      tags = MPTree.parse_id3v1('song.mp3', @options)

      assert_equal 'Title', tags['title']
      assert_equal 'Artist', tags['artist']
      assert_equal 'Album', tags['album']
      assert_equal '1991', tags['year']
      assert_equal '07', tags['track']
    end
  end

  def test_parse_id3v2_reads_basic_v23_text_frames
    in_tmpdir do
      frames = [
        id3v23_text_frame('TIT2', 'Title'),
        id3v23_text_frame('TPE1', 'Artist'),
        id3v23_text_frame('TALB', 'Album'),
        id3v23_text_frame('TYER', '1991'),
        id3v23_text_frame('TRCK', '7/12')
      ].join
      File.binwrite('song.mp3', 'ID3'.b + [3, 0, 0].pack('C*') + synchsafe(frames.bytesize) + frames)

      tags = MPTree.parse_id3v2('song.mp3', @options)

      assert_equal 'Title', tags['title']
      assert_equal 'Artist', tags['artist']
      assert_equal 'Album', tags['album']
      assert_equal '1991', tags['year']
      assert_equal '07', tags['track']
    end
  end

  private

  def in_tmpdir
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) { yield }
    end
  end

  def id3v1_tag
    comment = 'Comment'.b.ljust(28, "\x00".b) + "\x00".b + "\x07".b

    'TAG'.b +
      fixed('Title', 30) +
      fixed('Artist', 30) +
      fixed('Album', 30) +
      fixed('1991', 4) +
      comment +
      [0].pack('C')
  end

  def fixed(value, size)
    value.b.ljust(size, "\x00".b)
  end

  def id3v23_text_frame(id, value)
    body = "\x03".b + value.b
    id.b + [body.bytesize].pack('N') + "\x00\x00".b + body
  end

  def synchsafe(size)
    [
      (size >> 21) & 0x7f,
      (size >> 14) & 0x7f,
      (size >> 7) & 0x7f,
      size & 0x7f
    ].pack('C*')
  end
end
