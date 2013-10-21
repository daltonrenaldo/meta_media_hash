require "media_meta_hash/version"
require "video_info"
require 'ostruct'

module MediaMetaHash
  HASH_TYPE = Hash.new(:article)
  

  def self.for url, media_type = :video, opts = {}
    self.media_meta_hash(media_type, url, opts)
  end

  def self.video_info url
    if url =~ /video\.fox(news|business)\.com\/v\/(\d*)\/.*/
      partial_domain = $1
      id = $2
      OpenStruct.new(
        :video_id => id,
        :embed_url => "http://video.fox#{partial_domain}.com/v/video-embed.html?video_id=#{id}",
        :title => "",
        :image => "",
        :description  => "",
        :provider => "fox#{partial_domain}",
        :width => 480,
        :height => (480 * 0.5625).to_i
      )
    elsif url =~ /video\.cnbc\.com/ && url =~ /video=(\d*)/
      id = $1
      OpenStruct.new(
        :video_id => id,
        :embed_url => "http://video.cnbc.com/gallery/?video=#{id}",
        :title => "",
        :image => "",
        :description => "",
        :provider => "cnbc",
        :width => 480,
        :height => (480 * 0.5625).to_i
      )
    else
      info = VideoInfo.get(url)

      if url =~ /(youtube.com|youtu.be)/ && info
        class << info
          def og_url=(val)
            @url = val
          end

          def og_url
            @url
          end
        end
        info.og_url = self.get_video_src info.video_id
        info.width = 480 if info.width == nil
        info.height = (480 * 0.5625).to_i if info.height == nil
      end
      info
    end
  end

  def self.video_hash url, opts
    video = self.video_info(url)

    if video
      common = { :title => video.title,
                 :description => video.description,
                 :image => video.thumbnail_medium
               }

      { :og => { :video => [video.og_url || video.embed_url, 
                        {:height => video.height,
                          :width => video.width }],
                 :type => "video"
                }.merge!(common).merge!(opts),

        :twitter => { :player => [video.embed_url.sub("http://", "https://"),
                                  { :width => video.width,
                                    :height => video.height
                                  }],
                      :card => "player"
                    }.merge!(common).merge!(self.twitter_mobile(video.provider.downcase.to_sym, video.video_id)).merge!(opts)
      }
    else 
      {}.merge!(opts)
    end

  end

  def self.article_hash url, opts
    { :og => { :url => url }.merge!(opts), :twitter => {}.merge!(opts) }
  end

  private

  def self.ios_youtube_url id
    "vnd.youtube://watch/#{id}"
  end

  def self.get_video_src id
    "http://www.youtube.com/v/#{id}?autohide=1&version=3"
  end

  def self.media_meta_hash media_type, url, opts = {}
    if media_type == :video
      self.video_hash(url, opts)
    else
      self.article_hash(url, opts)
    end
  end

  def self.twitter_mobile provider, id
    tags_for = Hash.new({})
    tags_for[:youtube] = {
      :app => { :name => { :iphone => "YouTube",
                           :ipad => "YouTube",
                           :googleplay => "YouTube"
                         },
                :id => { :iphone => "544007664",
                         :ipad => "544007664",
                         :googleplay => "com.google.android.youtube"
                       },
                :url => { :iphone => self.ios_youtube_url(id),
                          :ipad => self.ios_youtube_url(id),
                          :googleplay => "http://www.youtube.com/watch/v=#{id}"
                        }
              }
    }
    tags_for[:vimeo] = { 
      :app => { :name => { :iphone => "Vimeo",
                           :ipad => "Vimeo",
                           :googleplay => "Vimeo"
                          },
                :id => { :iphone => "425194759",
                         :ipad => "425194759",
                         :googleplay => "com.vimeo.android.videoapp"
                        },
                :url => { :iphone => "vimeo://video/#{id}"}
            }

    }

    tags_for[provider]
  end

end
