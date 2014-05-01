#!/usr/bin/ruby

require 'fileutils'

videos = Dir.glob('*.{mp4,mkv}')

if ARGV.size > 0
  subtitles = ARGV
else
  subtitles = Dir.glob('*.{srt,ass,ssa}')
end

subtitles.each do |subtitle|
  if subtitle =~ /[^\d](?<episode>\d{2})[^\d]/
    episode = $~[:episode]
    matched_videos = videos.select do |video|
      video =~ Regexp.new("[^\d]#{episode}[^\d]")
    end
    if matched_videos.size > 0
      matched_video = matched_videos[0]
      dirname = File.dirname(matched_video)
      basename = File.basename(matched_video, '.*')
      subtitle_ext = File.extname(subtitle)
      wanted_subtitle = File.join(dirname, basename) + subtitle_ext
      FileUtils.cp(subtitle, wanted_subtitle)
    end
  end
end
