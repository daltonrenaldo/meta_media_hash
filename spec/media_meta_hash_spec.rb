require 'spec_helper'

describe MediaMetaHash do
  ARTICLE_URL = "http://google.com"
  YOUTUBE_URL = "http://www.youtube.com/watch?v=ZQCINxTQlN4"
  FOX_URL = "http://video.foxbusiness.com/v/2734961183001/a-breach-of-privacy-between-the-irs-and-white-house/"
  VIMEO_URL = "http://vimeo.com/74868773"
  CNBC_URL = "http://video.cnbc.com/gallery/?play=1&video=3000146612"

  def basic_info opts = {}
    OpenStruct.new({:title => "Boats", 
                    :description => "Something", 
                    :image => "http://image.com", 
                    :type => "video", 
                    :provider => "vimeo",
                    :embed_url => "http://embed_link.com",
                    :width => "240",
                    :height => "100",
                    :video_id => "13142"
                  }.merge!(opts))
  end

  describe "#get" do
    context ":article" do
      before do
        @result = MediaMetaHash.for(ARTICLE_URL, :article)
      end
    
      it "should return a hash" do
        @result.should be_instance_of Hash
      end

      it "should contains these keys" do
        @result.should include(:og, :twitter)
      end
    end

    context ":video" do
      before do
        @result = MediaMetaHash.for(YOUTUBE_URL)
      end

      it "should return a hash" do
        @result.should be_instance_of Hash
      end

      it "should contains these keys" do
        @result.should include(:og, :twitter)
      end
    end
  end

  describe "#video_info" do
    context "for fox videos" do
      it "returns object with correct attributes" do
        info = MediaMetaHash.video_info FOX_URL
        info.methods.should include(:video_id, :embed_url, :title, :image, :description, :provider, :width, :height)
      end
    end

    context "for cnbc videos" do
      it "returns object with correct attributes" do
        info = MediaMetaHash.video_info CNBC_URL
        info.methods.should include(:video_id, :embed_url, :title, :image, :description, :provider, :width, :height)
      end
    end

    context "for youtube videos" do
      before do
        VideoInfo.stub(:get).and_return{ basic_info({:thumbnail_medium => "url"}) }
      end

      it "returns object with correct attributes" do
        url = "http://www.youtube.com/watch?v=ZQCINxTQlN4"
        info = MediaMetaHash.video_info(url)
        info.methods.should include(:video_id, :embed_url, :title, :description, :provider, :width, :height, :thumbnail_medium, :og_url)
      end
    end

    context "for other videos" do
      before do
        VideoInfo.stub(:get).and_return{ basic_info }
      end

      it "returns object with correct attritubes" do
        url = "http://vimeo.com/74868773"
        info = MediaMetaHash.video_info(url)
        info.methods.should_not include(:og_url)
      end
    end

    context "for unsupported videos" do
      it "returns nil" do
        url = "http://video.com/2552524"
        info = MediaMetaHash.video_info(url)
        info.should be_nil
      end
    end
  end

  describe "#video_hash" do
    it "gets video info" do
      url = "http://vimeo.com/74868773"
      MediaMetaHash.should_receive(:video_info).and_return { basic_info }
      MediaMetaHash.video_hash url, {}
    end

    context "for youtube videos" do
      before do
        MediaMetaHash.stub(:video_info).and_return{ basic_info({:og_url => "http://og_url.com", :provider => :youtube}) }
        @info_hash = MediaMetaHash.video_hash YOUTUBE_URL, {}
      end

      it "the :og key" do
        @info_hash[:og].should include(:title, :description, :image, :type, :video)
      end

      it "the :twitter key" do
        @info_hash[:twitter].should include(:title, :description, :image, :player, :card, :app)
      end

      it "the :twitter => :player should be an array" do
        @info_hash[:twitter][:player].should be_instance_of Array
      end

      it "the :twitter => :player url (array.first) should be secure" do
        @info_hash[:twitter][:player].first.should match(/^https/)
      end

      it "the :twitter => :player array should have hash" do
        @info_hash[:twitter][:player].last.should include(:width, :height)
      end

      it "the :og => :video key" do
        @info_hash[:og][:video].should ==  ["http://og_url.com", {:height => "100", :width => "240"}]
      end

      it "the :twitter => :app key" do
        @info_hash[:twitter][:app].should include(:id, :name, :url)
      end

      it "the :twitter => :app => :id key" do
        @info_hash[:twitter][:app][:id].should include(:iphone, :ipad, :googleplay)
      end

      it "the :twitter => :app => :name key" do
        @info_hash[:twitter][:app][:name].should include(:iphone, :ipad, :googleplay)
      end

      it "the :twitter => :app => :url key" do
        @info_hash[:twitter][:app][:url].should include(:iphone, :ipad, :googleplay)
      end
    end

    context "for fox videos" do
      before do 
        MediaMetaHash.stub(:video_info).and_return{ basic_info({:provider => "foxbusiness"}) }
        @info_hash = MediaMetaHash.video_hash FOX_URL, {}
      end

      it "the :og => :video key" do
        @info_hash[:og][:video].should == ["http://embed_link.com", {:height => "100", :width => "240"}]
      end

      it "the :twitter key" do
        @info_hash[:twitter].should_not include(:app)
      end
    end
  end
end